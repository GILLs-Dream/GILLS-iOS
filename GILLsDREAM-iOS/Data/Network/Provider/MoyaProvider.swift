//
//  MoyaProvider.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/28/25.
//

import Foundation
import Moya
import Alamofire

public struct EmptyResponse: Decodable { }

public extension MoyaProvider {
    /// Moya callback → async/await 변환
    func asyncRequest(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { cont in
            self.request(target) { result in
                switch result {
                case .success(let res): cont.resume(returning: res)
                case .failure(let err): cont.resume(throwing: err)
                }
            }
        }
    }
    
    /// 공통 요청 + 디코딩 + 에러 매핑
    func requestDecodableAutoRefresh<T: Decodable>(
        _ target: Target,
        as type: T.Type,
        decoder: JSONDecoder = JSONDecoder(),
        attempt: Int = 0,
        maxRetry: Int = 1
    ) async throws -> T {
        do {
            let res = try await asyncRequest(target)
            
            switch res.statusCode {
            case 200..<300:
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                guard !res.data.isEmpty else {
                    let ctx = DecodingError.Context(codingPath: [], debugDescription: "Empty body for \(T.self)")
                    throw NetworkError.decoding(.dataCorrupted(ctx))
                }
                return try decoder.decode(T.self, from: res.data)
                
            case 401, 403:
                guard attempt < maxRetry else {
                    return try decodeServerError(res, decoder: decoder)
                }
                if let path = res.request?.url?.path, path.contains("/member/reissue") {
                    return try decodeServerError(res, decoder: decoder)
                }
                guard KeychainManager.shared.refreshToken != nil else {
                    return try decodeServerError(res, decoder: decoder)
                }
                
                let ok = try await refreshTokensAwait()
                if ok {
                    return try await requestDecodableAutoRefresh(
                        target, as: T.self, decoder: decoder, attempt: attempt + 1, maxRetry: maxRetry
                    )
                } else {
                    AuthService.shared.forceLogout()
                    return try decodeServerError(res, decoder: decoder)
                }
                
            default:
                return try decodeServerError(res, decoder: decoder)
            }
        } catch {
            throw error
        }
    }
    
    private func decodeServerError<T>(_ res: Response, decoder: JSONDecoder) throws -> T {
        if let apiErr = try? decoder.decode(ErrorResponse.self, from: res.data) {
            throw NetworkError.server(apiErr, status: res.statusCode)
        } else {
            let fallbackMsg = String(data: res.data, encoding: .utf8) ?? "HTTP \(res.statusCode)"
            let fallback = ErrorResponse(code: "HTTP_\(res.statusCode)", message: fallbackMsg)
            throw NetworkError.server(fallback, status: res.statusCode)
        }
    }
    
    private func refreshTokensAwait() async throws -> Bool {
        try await withCheckedThrowingContinuation { cont in
            let starter = RefreshCoordinator.shared.enqueue { _ in }
            if !starter {
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                    cont.resume(returning: KeychainManager.shared.accessToken != nil)
                }
                return
            }

            AuthService.shared.reissue { ok in
                if ok {
                    RefreshCoordinator.shared.finish(.retry)
                    cont.resume(returning: true)
                } else {
                    RefreshCoordinator.shared.finish(.doNotRetry)
                    cont.resume(returning: false)
                }
            }
        }
    }
}

extension MoyaProvider where Target: TargetType {
    convenience init(auth: AuthType) {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always

        let chain = Interceptor(adapters: [UserAuthInterceptor.shared],
                                retriers: [UserAuthInterceptor.shared])

        let monitors: [EventMonitor] = [AFEventLogger()]

        let session: Alamofire.Session = {
            switch auth {
            case .none:
                return Alamofire.Session(configuration: config) //,
                                         //eventMonitors: monitors)
            case .user:
                return Alamofire.Session(configuration: config,
                                         interceptor: chain) //,
                                         // eventMonitors: monitors)
            }
        }()

        let plugins: [PluginType]
        #if DEBUG
        plugins = [MoyaLoggingPlugin()] //, ResponseKindPlugin()]
        #else
        plugins = []
        #endif
        self.init(session: session, plugins: plugins)
    }
}
