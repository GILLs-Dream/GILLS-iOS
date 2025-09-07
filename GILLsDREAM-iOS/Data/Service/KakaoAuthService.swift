//
//  AuthService.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

protocol KakaoAuthServiceType {
    func fetchAuthCode() async throws -> String
}

final class KakaoAuthService: KakaoAuthServiceType {
    @MainActor
    func fetchAuthCode() async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            // 공통 완료 핸들러: 모든 경로에서 반드시 resume
            let done: (String?, Error?) -> Void = { code, error in
                if let code {
                    cont.resume(returning: code)
                } else {
                    cont.resume(throwing: error ?? NSError(domain: "kakao", code: -1))
                }
            }
            
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("loginWithKakaoTalk() success.")
                        _ = oauthToken
                    }
                }
            }
        }
    }
}
