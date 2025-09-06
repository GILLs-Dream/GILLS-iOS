//
//  ApiResponse.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/27/25.
//

struct ApiResponse<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T?
}
