//
//  User.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

struct User: Identifiable, Equatable, Hashable {
    let id: Int
    var nickname: String
    var email: String
    var profileImage: String?
    var provider: SocialProvider
    var marketingAgreement: Bool = false
}

public enum SocialProvider: String, Codable {
    case apple, kakao
}

struct MemberInfo {
    let id: Int
    let email: String
    let nickname: String
}
