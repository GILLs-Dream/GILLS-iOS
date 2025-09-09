//
//  PlanListRequestDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/9/25.
//

struct PlanListRequestDTO: Decodable {
    let planList: [PlanListItemDTO]
}

struct PlanListItemDTO: Decodable {
    let planId: Int
    let title: String
    let startedAt: String
    let finishedAt: String
    let thumbnailUrl: String
}
