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
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.request(target) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch let error as MoyaError {
            // 401 처리: access token 재발급 후 재요청
            if case .statusCode(let response) = error, response.statusCode == 401 {
                let newAccessToken = try await AuthUsecaseImpl().refreshAccessTokenIfNeeded()
                // 같은 target 다시 요청
                return try await withCheckedThrowingContinuation { continuation in
                    self.request(target) { result in
                        switch result {
                        case .success(let response):
                            continuation.resume(returning: response)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            } else { throw error }
        }
    }
    
    /// 공통 요청 + 디코딩 + 에러 매핑
    func requestDecodable<T: Decodable>(
        _ target: Target,
        as type: T.Type,
        decoder: JSONDecoder = {
            let d = JSONDecoder()
            return d
        }()
    ) async throws -> T {
        do {
            let res = try await asyncRequest(target)
            
            switch res.statusCode {
            case 200..<300:
                if T.self == EmptyResponse.self { return EmptyResponse() as! T }
                guard res.data.isEmpty == false else {
                    let ctx = DecodingError.Context(codingPath: [], debugDescription: "Empty body for \(T.self)")
                    throw NetworkError.decoding(.dataCorrupted(ctx))
                }
                do {
                    return try decoder.decode(T.self, from: res.data)
                } catch let e as DecodingError {
                    throw NetworkError.decoding(e)
                } catch {
                    throw NetworkError.unknown(error)
                }
                
            default:
                // 서버 에러 바디 시도 파싱
                if let apiErr = try? decoder.decode(ErrorResponse.self, from: res.data) {
                    if apiErr.code == "MEMBER NOT FOUND" {
                        NotificationCenter.default.post(
                            name: .appAuthMemberNotFound,
                            object: nil
                        )
                        throw AppAuthError.memberNotFound
                    }
                    throw NetworkError.server(apiErr, status: res.statusCode)
                } else {
                    let fallbackMsg = String(data: res.data, encoding: .utf8) ?? "HTTP \(res.statusCode)"
                    let fallback = ErrorResponse(code: "HTTP_\(res.statusCode)", message: fallbackMsg)
                    throw NetworkError.server(fallback, status: res.statusCode)
                }
            }
        } catch let cancelErr as CancellationError {
            throw cancelErr
        } catch let moyaErr as MoyaError {
            if case let .underlying(underlying, _) = moyaErr,
               let urlErr = underlying as? URLError {
                throw NetworkError.transport(urlErr)
            }
            throw NetworkError.unknown(moyaErr)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

extension MoyaProvider where Target: TargetType {
    convenience init(auth: AuthType) {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always
        
        let session: Alamofire.Session = {
            switch auth {
            case .none: return Alamofire.Session(configuration: config)
            case .user: return Alamofire.Session(configuration: config,
                                                 interceptor: UserAuthInterceptor.shared)
            }
        }()
        
        let plugins: [PluginType]
#if DEBUG
        plugins = [MoyaLoggingPlugin()]
#else
        plugins = []
#endif
        self.init(session: session, plugins: plugins)
    }
}
