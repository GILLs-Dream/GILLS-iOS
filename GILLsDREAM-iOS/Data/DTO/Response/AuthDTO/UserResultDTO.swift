//
//  UserResultDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/1/25.
//

struct UserResultDTO: Decodable {
    let userId: String
    let nickname: String
    let profileImageURL: String?
    let provider: SocialProvider
}
