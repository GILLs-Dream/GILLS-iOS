//
//  PlanGenerateResponseDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/12/25.
//

struct PlanResultResponseDTO: Decodable {
    let title: String
    let planId: Int
    let duration: Int
    let planPerDayDtoList: [PlanPerDayDTO]
}

struct PlanPerDayDTO: Decodable {
    let dayNum: Int
    let from: PlanPlaceDTO
    let routeDtoList: [PlanRouteDTO]
}

struct PlanRouteDTO: Decodable {
    let cnt: Int
    let to: PlanPlaceDTO
    let distance: Double
    let time: Double
}

struct PlanPlaceDTO: Decodable {
    let placeId: Int
    let name: String
    let mainImg: String
}

struct PlanSummaryResponseDTO: Decodable {
    let title: String
    let summary: String
}
