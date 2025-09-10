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
    static let plan   = MoyaProvider<PlanTargetType>(auth: .user)
}

// MARK: User 토큰 인터셉터
final class UserAuthInterceptor: RequestInterceptor {
    static let shared = UserAuthInterceptor()
    private init() {}
    
    // 동시 만료 대응
    private let lock = NSLock()
    private var isRefreshing = false
    private var pendingCompletions: [(RetryResult) -> Void] = []
    
    func adapt(_ urlRequest: URLRequest,
               for session: Alamofire.Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        let token = KeychainManager.shared.accessToken
        completion(.success(req))
    }
    
    func retry(_ request: Request, for session: Session,
               dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetry); return
        }

        let status = response.statusCode // 만료 신호 -> 리프레시
        let isAuthError = (status == 401 || status == 403)
        guard isAuthError else { completion(.doNotRetry); return }

        guard let refresh = KeychainManager.shared.refreshToken, !refresh.isEmpty else { // 토큰 없으면 로그아웃
            self.forceLogout(); completion(.doNotRetry); return
        }

        lock.lock() // 동시 호출 방지 큐잉
        pendingCompletions.append(completion)
        let shouldStartRefresh = !isRefreshing
        isRefreshing = true
        lock.unlock()

        guard shouldStartRefresh else { return } // 이미 다른 요청이 리프레시 중

        refreshTokens(refreshToken: refresh) { [weak self] result in
            guard let self else { return }
            self.lock.lock()
            let completions = self.pendingCompletions
            self.pendingCompletions.removeAll()
            self.isRefreshing = false
            self.lock.unlock()

            switch result {
            case .success:
                // 새 토큰으로 모두 재시도
                completions.forEach { $0(.retry) }
            case .failure:
                // 재발급 실패 → 강제 로그아웃
                self.forceLogout()
                completions.forEach { $0(.doNotRetry) }
            }
        }
    }
    
    private func refreshTokens(refreshToken: String,
                               done: @escaping (Result<Void, Error>) -> Void) {
        let provider = Providers.memberPublic
        provider.request(.reissue(refreshToken: refreshToken)) { result in
            switch result {
            case .success(let res) where (200..<300).contains(res.statusCode):
                struct ReissueDTO: Decodable {
                    let access_token: String
                    let refresh_token: String
                }
                do {
                    let dto = try JSONDecoder().decode(ReissueDTO.self, from: res.data)
                    KeychainManager.shared.accessToken = dto.access_token
                    KeychainManager.shared.refreshToken = dto.refresh_token
                    done(.success(()))
                } catch {
                    done(.failure(error))
                }

            case .success(let res):
                // 서버가 member not found 등 반환할 수도 있음
                if let api = try? JSONDecoder().decode(ErrorResponse.self, from: res.data),
                   api.code == "MEMBER NOT FOUND" {
                    done(.failure(NSError(domain: "auth", code: 404)))
                } else {
                    done(.failure(NSError(domain: "auth", code: res.statusCode)))
                }

            case .failure(let err):
                done(.failure(err))
            }
        }
    }
    
    private func forceLogout() {
        KeychainManager.shared.accessToken = nil
        KeychainManager.shared.refreshToken = nil
        UserDefaultsManager.shared.isLogin = false
        UserDefaultsManager.shared.isOnboarding = false
        NotificationCenter.default.post(name: .needReLogin, object: nil)
    }
}

extension Notification.Name {
    static let needReLogin = Notification.Name("needReLogin")
    static let appAuthMemberNotFound = Notification.Name("no member")
}
