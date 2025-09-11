//
//  AuthRepository.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

import UIKit
import Moya

protocol AuthRepository {
    func exchangeKakaoToken(_ kakaoAccess: String) async throws -> (access: String, refresh: String)
    func logout() async throws
    func updateSetting(nickname: String, marketingAgreement: Bool, imageData: Data?) async throws -> SettingResponseDTO
    func reissue(access: String?, refresh: String) async throws -> ReissueResponseDTO
    func fetchMemberInfo() async throws -> InfoResponseDTO
    func deleteAccount() async throws
}
