//
//  LoginRequestDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/1/25.
//

struct LoginRequestDTO: Encodable {
    let provider: SocialProvider
    let oauthAccessToken: String   // 카카오: KA SDK 발급 access token
    // 애플을 붙이면: authorizationCode / idToken 등으로 필드 추가 가능
}
