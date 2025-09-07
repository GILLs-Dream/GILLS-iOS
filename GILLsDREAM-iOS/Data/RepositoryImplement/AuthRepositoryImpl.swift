//
//  AuthRepositoryImpl.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let provider = Providers.member

    func kakaoLogin(code: String) async throws -> Session {
        let res = try await provider.asyncRequest(.kakaoLogin(code: code))

        let api = try JSONDecoder().decode(ApiResponse<LoginResultDTO>.self, from: res.data)
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: res.statusCode)
        }

        // 헤더/쿠키에서 토큰 파싱, 저장
        if let access = TokenParser.accessToken(from: res) {
            KeychainManager.shared.accessToken = access
        }
        if let refresh = TokenParser.refreshToken(from: res, cookieName: "refreshToken") {
            KeychainManager.shared.refreshToken = refresh
        }

        UserDefaultsManager.shared.isLogin = true
        return Session(memberId: dto.memberId, email: dto.email)
    }
}
