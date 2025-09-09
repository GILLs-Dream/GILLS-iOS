//
//  AuthRepositoryImpl.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import UIKit
import Moya

final class AuthRepositoryImpl: AuthRepository {
    private let provider = Providers.member
    
    func exchangeKakaoToken(_ kakaoAccess: String) async throws -> (access: String, refresh: String) {
        let res = try await provider.asyncRequest(.kakaoLogin(accessToken: kakaoAccess))
        let dto = try JSONDecoder().decode(KakaoLoginResponseDTO.self, from: res.data)
        return (dto.accessToken, dto.refreshToken)
    }
    
    func logout() async throws {
        _ = try await provider.asyncRequest(.logout)
    }
    
    func updateSetting(nickname: String, profileImg: UIImage?, marketingAgreement: Bool) async throws -> SettingResponseDTO {
        let res = try await provider.asyncRequest(
            .setting(nickname: nickname, marketingAgreement: marketingAgreement, image: profileImg))
        let api = try JSONDecoder().decode(ApiResponse<SettingResponseDTO>.self, from: res.data)
        
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: res.statusCode)
        }
        return dto
    }
    
    func deleteAccount() async throws {
        _ = try await provider.asyncRequest(.delete)
    }
}
