//
//  ErrorResponse.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/26/25.
//

import Foundation

public enum NetworkError: Error {
    case server(ErrorResponse, status: Int)
    case transport(URLError)
    case decoding(DecodingError)
    case unknown(Error)
}

public struct ErrorResponse: Decodable {
    public let code: String
    public let message: String
}
