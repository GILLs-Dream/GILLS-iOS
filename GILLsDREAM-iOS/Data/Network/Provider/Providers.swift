//
//  Providers.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import Foundation
import Moya
import Alamofire

enum AuthType {
    case none
    case user
}

// MARK: 공용 Providers
struct Providers {
    static let memberPublic = MoyaProvider<MemberTargetType>(auth: .none)
    static let memberUser = MoyaProvider<MemberTargetType>(auth: .user)
    static let plan = MoyaProvider<PlanTargetType>(auth: .user)
}

final class UserAuthInterceptor: RequestInterceptor {
    static let shared = UserAuthInterceptor()
    private init() {}
    
    func adapt(_ urlRequest: URLRequest,
               for session: Alamofire.Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
//        // 1) 만료 임박/만료 판단 (예: 만료까지 60초 미만이면 선발급)
//        if KeychainManager.shared.isAccessTokenExpired(earlyBy: 60) {
//            let starter = RefreshCoordinator.shared.enqueue { _ in /* no-op here */ }
//            if starter {
//                AuthService.shared.reissue { ok in
//                    if !ok {
//                        AuthService.shared.forceLogout()
//                    }
//                    // 큐에 쌓인 대기자들 깨우기
//                    RefreshCoordinator.shared.finish(.doNotRetry)
//                }
//            }
//            // 선발급이 끝날 때까지 큐에 합류해서 기다렸다가 헤더 부착
//            // finish가 호출되면 아래로 진행
//        }

        if let token = KeychainManager.shared.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
//        print("🟦 [ADAPT] \(req.httpMethod ?? "") \(req.url?.absoluteString ?? "")")
//        print("🟦 Headers:", req.allHTTPHeaderFields ?? [:])
        completion(.success(req))
    }
    
    // 401/403에서만 재발급 -> 원요청 재시도
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 || response.statusCode == 403 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        if request.retryCount >= 2 {        // 최대 2회
            completion(.doNotRetry); return
        }
        print("🟧 [RETRY?] status=\(response.statusCode), url=\(request.request?.url?.absoluteString ?? "")")

        if let path = request.request?.url?.path, path.contains("/member/reissue") {
            completion(.doNotRetry); return
        }

        guard KeychainManager.shared.refreshToken != nil else {
            completion(.doNotRetry); return
        }

        // 동시 재발급 방지
        let starter = RefreshCoordinator.shared.enqueue(completion)
        guard starter else { return }

        AuthService.shared.reissue { ok in
            if ok {
                print("🟩 [REISSUE] success → retry")
                RefreshCoordinator.shared.finish(.retry)
            } else {
                print("🟥 [REISSUE] failed → logout & doNotRetry")
                AuthService.shared.forceLogout()
                RefreshCoordinator.shared.finish(.doNotRetry)
            }
        }
    }
}

final class AFEventLogger: EventMonitor {
    let queue = DispatchQueue(label: "af.event.logger")

    func requestDidResume(_ request: Request) {
        print("🚀 requestDidResume:", request.request?.url?.absoluteString ?? "-")
    }
    func request(_ request: Request, didCreateInitialURLRequest urlRequest: URLRequest) {
        print("🧱 didCreateInitialURLRequest:", urlRequest.url?.absoluteString ?? "-")
    }
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        print("🧱 didCreateURLRequest:", urlRequest.url?.absoluteString ?? "-")
    }
    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: Error?) {
        print("📍 didCompleteTask error=\(String(describing: error))")
    }
    func requestIsRetrying(_ request: Request) {
        print("🔁 requestIsRetrying:", request.request?.url?.absoluteString ?? "-")
    }
}
final class ResponseKindPlugin: PluginType {
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let resp):
            print("🟩 [MOYA SUCCESS] status=\(resp.statusCode), url=\(resp.request?.url?.absoluteString ?? "")")
        case .failure(let err):
            print("🟥 [MOYA FAILURE] err=\(err), path=\(target.path)")
        }
    }
}

// 동시 재발급 1회 보장
final class RefreshCoordinator {
    static let shared = RefreshCoordinator()
    private init() {}
    
    private let queue = DispatchQueue(label: "auth.refresh.queue", qos: .userInitiated)
    private var isRefreshing = false
    private var waiters: [(RetryResult) -> Void] = []
    
    func enqueue(_ completion: @escaping (RetryResult) -> Void) -> Bool {
        var shouldStart = false
        queue.sync {
            waiters.append(completion)
            if !isRefreshing {
                isRefreshing = true
                shouldStart = true
            }
        }
        return shouldStart
    }
    
    func finish(_ result: RetryResult) {
        var completions: [(RetryResult) -> Void] = []
        queue.sync {
            completions = waiters
            waiters.removeAll()
            isRefreshing = false
        }
        completions.forEach { $0(result) }
    }
}

extension Notification.Name {
    static let needReLogin = Notification.Name("needReLogin")
    static let appAuthMemberNotFound = Notification.Name("no member")
}
