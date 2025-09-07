//
//  ApiResponse.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/27/25.
//

///서버가 정상 응답을 줄 때 사용하는 모델
struct ApiResponse<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T?
}
