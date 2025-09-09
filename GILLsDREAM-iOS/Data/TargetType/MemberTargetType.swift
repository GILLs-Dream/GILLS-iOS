//
//  MemberTargetType.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

import Moya
import UIKit

enum MemberTargetType {
    case kakaoLogin(accessToken: String)
    case logout
    case setting(nickname: String, marketingAgreement: Bool, image: UIImage?)
    case reissue(refreshToken: String)
    case delete
}

extension MemberTargetType: BaseTargetType {
    var path: String {
        switch self {
        case .kakaoLogin:
            return "/v1/member/oauth/kakao/login"
        case .logout:
            return "/v1/member/logout"
        case .setting:
            return "/v1/member/setting"
        case .reissue:
            return "/v1/member/reissue"
        case .delete:
            return "/v1/member/delete"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .kakaoLogin, .logout:
            return .post
        case .setting:
            return .patch
        case .reissue:
            return .get
        case .delete:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .kakaoLogin(let accessToken):
            return .requestParameters(parameters: ["accessToken": accessToken],
                                      encoding: URLEncoding.queryString)
        case .logout, .delete:
            return .requestPlain
            
        case let .setting(nickname, marketingAgreement, image):
            var parts: [MultipartFormData] = []
            // text
            parts.append(.init(provider: .data(Data(nickname.utf8)), name: "nickname"))
            parts.append(.init(provider: .data(Data(String(marketingAgreement).utf8)), name: "marketingAgreement"))

            // img
            if let image, let data = image.jpegData(compressionQuality: 0.9) {
                parts.append(.init(provider: .data(data),
                                   name: "profileImg",
                                   fileName: "profile.jpg",
                                   mimeType: "image/jpeg"))
            }
            return .uploadMultipart(parts)
            
        case .reissue(let refresh):
            return .requestParameters(parameters: ["refresh_token": refresh],
                                      encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .setting:
            return ["Content-Type": "multipart/form-data"]
            
        case .reissue(let refresh):
            return ["X-Refresh-Token": refresh]
            
        default:
            var base: [String: String] = ["Content-Type": "application/json"]
            if let token = KeychainManager.shared.accessToken {
                base["Authorization"] = "Bearer \(token)"
            }
            return base
        }
    }
}
