//
//  MemberTargetType.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

import Moya

enum MemberTargetType {
    case kakaoLogin(code: String)
    case kakaoLogout
    case setting(nickname: String, agreedTerms: Bool)
    case reissue(refreshToken: String)
}

extension MemberTargetType: BaseTargetType {
    var path: String {
        switch self {
        case .kakaoLogin:
            return "/member/oauth/kakao/login"
        case .kakaoLogout: 
            return "/member/oauth/kakao/logout"
        case .setting:     
            return "/member/setting"
        case .reissue:     
            return "/member/reissue"
        }
    }
    var method: Moya.Method {
        switch self {
        case .kakaoLogin, .kakaoLogout:
            return .post
        case .setting:
            return .patch
        case .reissue:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .kakaoLogin(let code):
            return .requestParameters(parameters: ["code": code, "provider": "kakao"],
                                      encoding: JSONEncoding.default)
        case .kakaoLogout:
            return .requestPlain
            
        case let .setting(nickname, agreed):
            return .requestJSONEncodable(SettingRequestDTO(nickname: nickname,
                                                           agreedTerms: agreed))
        case .reissue(let refresh):
            return .requestParameters(parameters: ["refreshToken": refresh],
                                      encoding: URLEncoding.queryString)
        }
    }
}
