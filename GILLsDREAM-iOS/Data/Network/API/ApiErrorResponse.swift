//
//  ApiErrorResponse.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/27/25.
//

struct ApiErrorResponse: Decodable {
    let isSuccess: Bool?
    let code: String?
    let message: String?
    let result: String?
}
