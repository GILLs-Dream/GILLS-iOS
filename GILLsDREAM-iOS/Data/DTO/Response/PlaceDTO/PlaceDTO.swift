//
//  PlaceDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/12/25.
//

struct PlaceDTO: Decodable {
    let platform: String
    let contentId: String
    let placeType: String
    let detailUrl: String
    let imageUrl: String?
    let period: PeriodDTO
}

struct PeriodDTO: Decodable {
    let startedAt: String
    let finishedAt: String
    let duration: Int?
    let dayOrder: Int
}
