//
//  ReissueResultDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/1/25.
//

struct ReissueResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken  = "access_token"
        case refreshToken = "refresh_token"
    }
}
