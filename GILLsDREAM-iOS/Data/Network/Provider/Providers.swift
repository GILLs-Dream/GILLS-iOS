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
    static let member = MoyaProvider<MemberTargetType>(auth: .none)
    static let plan   = MoyaProvider<PlanTargetType>(auth: .user)
}

// MARK: User 토큰 인터셉터
final class UserAuthInterceptor: RequestInterceptor {
    static let shared = UserAuthInterceptor()
    private init() {}

    func adapt(_ urlRequest: URLRequest,
               for session: Alamofire.Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        if let token = KeychainManager.shared.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(req))
    }
}

