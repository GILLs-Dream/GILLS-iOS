//
//  AuthRepository.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

import Foundation

protocol AuthRepository {
    func signIn(code: String) async throws -> Session
    func refresh(_ refreshToken: String) async throws -> Session
    func signOut() async throws
}
