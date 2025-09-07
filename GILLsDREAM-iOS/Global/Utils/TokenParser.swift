//
//  TokenParser.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import Foundation
import Moya

enum TokenParser {
    static func accessToken(from response: Response) -> String? {
        // HTTPURLResponse 헤더에서 Authorization 추출
        guard let headers = response.response?.allHeaderFields as? [String: Any] else { return nil }
        let key = headers.keys.first {
            $0.lowercased() == "authorization"
        }
        guard let raw = key.flatMap({ headers[$0] as? String }) else { return nil }

        // "Bearer xxx.yyy.zzz" 형태에서 토큰만 분리
        if raw.lowercased().hasPrefix("bearer ") {
            return String(raw.dropFirst("Bearer ".count))
        } else {
            return raw
        }
    }

    static func refreshToken(from response: Response, cookieName: String = "refreshToken") -> String? {
        // 응답 URL 기준 쿠키만 필터(가장 안전)
        guard let url = response.request?.url else {
            // URL이 없으면 전체 cookie 목록에서 탐색
            return HTTPCookieStorage.shared.cookies?
                .first(where: { $0.name == cookieName })?.value
        }
        return HTTPCookieStorage.shared.cookies(for: url)?
            .first(where: { $0.name == cookieName })?.value
    }
}
