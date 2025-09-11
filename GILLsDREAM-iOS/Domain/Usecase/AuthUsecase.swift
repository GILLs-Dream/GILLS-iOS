//
//  AuthUsecase.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/9/25.
//

import UIKit

protocol AuthUsecase {
    func loginWithKakao(accessToken: String) async throws
    func logout() async throws
    func updateSetting(nickname: String, profileImg: UIImage?, agreed: Bool) async throws -> SettingResponseDTO
    func refreshAccessTokenIfNeeded() async throws -> String
    func getInfo() async throws -> MemberInfo
    func deleteAccount() async throws
}

final class AuthUsecaseImpl: AuthUsecase {
    private let repo: AuthRepository
    init(repo: AuthRepository = AuthRepositoryImpl()) { self.repo = repo }

    func loginWithKakao(accessToken: String) async throws {
        let tokens = try await repo.exchangeKakaoToken(accessToken)
        KeychainManager.shared.accessToken = tokens.access
        KeychainManager.shared.refreshToken = tokens.refresh
        UserDefaultsManager.shared.isLogin = true
    }

    func logout() async throws {
        try await repo.logout()
        KeychainManager.shared.accessToken = nil
        KeychainManager.shared.refreshToken = nil
        UserDefaultsManager.shared.isLogin = false
    }

    func updateSetting(nickname: String, profileImg: UIImage?, agreed: Bool) async throws -> SettingResponseDTO {
        let result = try await repo.updateSetting(nickname: nickname,
                                                  profileImg: profileImg,
                                                  marketingAgreement: agreed)
        UserDefaultsManager.shared.isOnboarding = true
        return result
    }
    
    func refreshAccessTokenIfNeeded() async throws -> String {
        guard let refresh = KeychainManager.shared.refreshToken else {
            throw NetworkError.unauthorized
        }
        let dto = try await repo.reissue(access: KeychainManager.shared.accessToken, refresh: refresh)
        KeychainManager.shared.accessToken  = dto.accessToken
        KeychainManager.shared.refreshToken = dto.refreshToken
        return dto.accessToken
    }
    
    func getInfo() async throws -> MemberInfo {
        let dto = try await repo.fetchMemberInfo()
        return AuthMapper.toMemberInfo(dto)
    }

    func deleteAccount() async throws {
        try await repo.deleteAccount()
        KeychainManager.shared.accessToken = nil
        KeychainManager.shared.refreshToken = nil
        UserDefaultsManager.shared.isLogin = false
        UserDefaultsManager.shared.isOnboarding = false
    }
}
