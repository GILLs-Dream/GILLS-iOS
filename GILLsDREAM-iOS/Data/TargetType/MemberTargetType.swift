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
    case setting(nickname: String, marketingAgreement: Bool, imageData: Data?)
    case reissue(refreshToken: String)
    case info
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
        case .info:
            return "/v1/member/info"
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
        case .reissue, .info:
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
        case .logout, .info, .delete:
            return .requestPlain
            
        case let .setting(nickname, marketingAgreement, imageData):
            var parts: [MultipartFormData] = []

            // profile part
            struct ProfilePayload: Encodable {
                let nickname: String
                let marketingAgreement: Bool
            }
            
            let payload = ProfilePayload(nickname: nickname,
                                         marketingAgreement: marketingAgreement)
            
            if let jsonData = try? JSONEncoder().encode(payload) {
                parts.append(
                    MultipartFormData(
                        provider: .data(jsonData),
                        name: "profile",
                        fileName: "profile.json",
                        mimeType: "application/json"
                    )
                )
            }

            // image part
            if let data = imageData {
                parts.append(
                    MultipartFormData(
                        provider: .data(data),
                        name: "image",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }
            return .uploadMultipart(parts)
            
        case .reissue(let refresh):
            return .requestParameters(parameters: ["refresh_token": refresh],
                                      encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .kakaoLogin:
            return ["Content-Type": "application/json"]
            
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
