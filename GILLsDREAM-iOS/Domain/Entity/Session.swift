//
//  Session.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

import Foundation

struct Session: Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    var isValid: Bool { Date() < expiresAt }
}
