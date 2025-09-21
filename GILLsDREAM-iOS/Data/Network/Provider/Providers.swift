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
        if req.url?.path.contains("/member/reissue") == true {
            completion(.success(req)); return
        }
        
        let current = KeychainManager.shared.accessToken ?? ""

        if !current.isEmpty, KeychainManager.shared.isAccessTokenExpired(earlyBy: 600) {
            let started = RefreshCoordinator.shared.enqueue { _ in
                var newReq = req
                if let newToken = KeychainManager.shared.accessToken, !newToken.isEmpty {
                    newReq.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                } else {
                    newReq.setValue(nil, forHTTPHeaderField: "Authorization")
                }
                completion(.success(newReq))
            }
            if started {
                AuthService.shared.reissue { ok in
                    RefreshCoordinator.shared.finish(ok ? .retry : .doNotRetry)
                }
            }
            return
        }
        
        if !current.isEmpty {
            req.setValue("Bearer \(current)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(req))
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
