//
//  UserRepository.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

protocol UserRepository {
    func loadMe() async throws -> User
    func updateNickname(_ nickname: String) async throws -> User
}
