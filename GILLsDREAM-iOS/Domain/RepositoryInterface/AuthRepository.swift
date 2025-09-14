//
//  AuthRepository.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

import UIKit
import Moya

protocol AuthRepository {
    func kakaoLogin(accessToken: String) async throws -> LoginResponseDTO
    func appleLogin(identityToken: String) async throws -> LoginResponseDTO
    func logout() async throws
    func updateSetting(nickname: String, marketingAgreement: Bool, imageData: Data?) async throws -> SettingResponseDTO
    func reissue(access: String?, refresh: String) async throws -> ReissueResponseDTO
    func fetchMemberInfo() async throws -> InfoResponseDTO
    func deleteAccount() async throws
}
