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
    func updateSetting(nickname: String, profileImg: UIImage?, marketingAgreement: Bool) async throws -> SettingResponseDTO
    func deleteAccount() async throws
}
