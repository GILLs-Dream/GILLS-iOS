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
    case unauthorized

    public var message: String {
        switch self {
        case .server(let err, _):
            return err.message ?? "no error message"
        case .transport:
            return "네트워크 상태를 확인해 주세요."
        case .decoding:           
            return "응답 처리 중 문제가 발생했어요."
        case .unknown:            
            return "알 수 없는 오류가 발생했어요."
        case .unauthorized:
            return "토큰 만료"
        }
    }
}

/// 서버 에러 바디를 담는 DTO
public struct ErrorResponse: Decodable {
    public let code: String?
    public let message: String?
}

extension Error {
    var displayMessage: String {
        (self as? NetworkError)?.message ?? self.localizedDescription
    }
}
