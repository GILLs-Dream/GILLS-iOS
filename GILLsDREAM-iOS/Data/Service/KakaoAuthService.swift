//
//  AuthService.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

enum KakaoLoginError: Error { case noToken }

final class KakaoAuthService {
    @MainActor
    func fetchAccessToken() async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            let finish: (OAuthToken?, Error?) -> Void = { token, err in
                if let t = token?.accessToken { cont.resume(returning: t) }
                else { cont.resume(throwing: err ?? KakaoLoginError.noToken) }
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: finish)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: finish)
            }
        }
    }
}
