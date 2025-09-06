//
//  LoginResultDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/1/25.
//

struct LoginResultDTO: Decodable {
    let userId: String
    let nickname: String
    let profileImageURL: String?
    let provider: SocialProvider
    let accessToken: String
    let refreshToken: String
    let expiresAt: String 
}
