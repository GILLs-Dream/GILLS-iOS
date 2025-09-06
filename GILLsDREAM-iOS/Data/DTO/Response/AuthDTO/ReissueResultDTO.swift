//
//  ReissueResultDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/1/25.
//

struct ReissueResultDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
}
