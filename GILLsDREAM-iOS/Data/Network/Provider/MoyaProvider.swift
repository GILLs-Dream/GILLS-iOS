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
                case .success(let res):
                    cont.resume(returning: res)
                case .failure(let err):
                    cont.resume(throwing: err)
                }
            }
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
                // 빈 바디 허용 (T == EmptyResponse)
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                guard res.data.isEmpty == false else {
                    // 빈 바디인데 T가 EmptyResponse가 아니면 디코딩 에러로 처리
                    let ctx = DecodingError.Context(codingPath: [],
                                                    debugDescription: "Empty body for \(T.self)")
                    throw NetworkError.decoding(.dataCorrupted(ctx))
                }
                do {
                    return try decoder.decode(T.self, from: res.data)
                } catch let e as DecodingError {
                    throw NetworkError.decoding(e)
                } catch {
                    throw NetworkError.unknown(error)
                }
                
            default: // 서버에러 바디 매핑
                if let apiErr = try? decoder.decode(ErrorResponse.self, from: res.data) {
                    throw NetworkError.server(apiErr, status: res.statusCode)
                } else {
                    let fallback = ErrorResponse(
                        code: "HTTP_\(res.statusCode)",
                        message: String(data: res.data, encoding: .utf8) ?? "HTTP \(res.statusCode)"
                    )
                    throw NetworkError.server(fallback, status: res.statusCode)
                }
            }
        }
        catch let cancelErr as CancellationError { // task 취소
            throw cancelErr
        }
        catch let moyaErr as MoyaError { // 전송에러 매핑
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
        let session: Alamofire.Session = {
            switch auth {
            case .none: return Alamofire.Session()
            case .user: return Alamofire.Session(interceptor: UserAuthInterceptor.shared)
            }
        }()
        
        #if DEBUG
        let plugins: [PluginType] = [MoyaLoggingPlugin()]
        #else
        let plugins: [PluginType] = []
        #endif

        self.init(session: session, plugins: plugins)
    }
}
