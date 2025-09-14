//
//  AuthRepositoryImpl.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import UIKit
import Moya

final class AuthRepositoryImpl: AuthRepository {
    private let publicProvider = Providers.memberPublic
    private let userProvider = Providers.memberUser
    
    func kakaoLogin(accessToken: String) async throws -> LoginResponseDTO {
        try await publicProvider.asyncRequest(.kakaoLogin(accessToken: accessToken), as: LoginResponseDTO.self)
    }
    
    func appleLogin(identityToken: String) async throws -> LoginResponseDTO {
        try await publicProvider.asyncRequest(.appleLogin(identityToken: identityToken), as: LoginResponseDTO.self)
    }
    
    func logout() async throws {
        _ = try await userProvider.asyncRequest(.logout)
    }
    
    func updateSetting(nickname: String, marketingAgreement: Bool, imageData: Data?) async throws -> SettingResponseDTO {
        let res = try await userProvider.asyncRequest(
            .setting(nickname: nickname,
                     marketingAgreement: marketingAgreement,
                     imageData: imageData)
        )
        let api = try JSONDecoder().decode(ApiResponse<SettingResponseDTO>.self, from: res.data)
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: res.statusCode)
        }
        return dto
    }
    
    func fetchMemberInfo() async throws -> InfoResponseDTO {
        let api: ApiResponse<InfoResponseDTO> = try await userProvider.requestDecodableAutoRefresh(
            .info,
            as: ApiResponse<InfoResponseDTO>.self
        )
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return dto
    }
    
    func reissue(access: String?, refresh: String) async throws -> ReissueResponseDTO {
        let res = try await publicProvider.asyncRequest(.reissue(refreshToken: refresh))
        return try JSONDecoder().decode(ReissueResponseDTO.self, from: res.data)
    }
    
    func deleteAccount() async throws {
        _ = try await userProvider.asyncRequest(.delete)
    }
}
