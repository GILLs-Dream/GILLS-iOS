//
//  LoginResponseDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/15/25.
//

struct LoginResponseDTO: Decodable {
    let memberId: Int
    let email: String?
    let accessToken: String
    let refreshToken: String
    let needOnboarding: Bool
    let loginType: LoginType
}

enum LoginType: String, Decodable {
    case KAKAO, APPLE
}
