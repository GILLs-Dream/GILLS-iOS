//
//  AuthMapper.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/11/25.
//

enum AuthMapper {
    static func toMemberInfo(_ dto: InfoResponseDTO) ->  MemberInfo {
        .init(id: dto.memberId, email: dto.email, nickname: dto.nickname)
    }
}
