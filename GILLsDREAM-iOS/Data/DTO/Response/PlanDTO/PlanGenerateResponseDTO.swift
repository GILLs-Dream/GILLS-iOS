//
//  PlanGenerateResponseDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/14/25.
//

struct PlanGenerateResponseDTO: Decodable {
    let mode: String
    let days: [PlanGenerateDayDTO]
}

struct PlanGenerateDayDTO: Decodable {
    let date: String?
    let index: Int
    let routes: [PlanGenerateRouteDTO]
}

struct PlanGenerateRouteDTO: Decodable {
    let distance: Double
    let duration: Double
    let polyline: String?
    let legs: [PlanGenerateLegDTO]
}

struct PlanGenerateLegDTO: Decodable {
    let startName: String
    let startLat: Double
    let startLng: Double
    let startPlace: PlanGeneratePlaceDTO

    let endName: String
    let endLat: Double
    let endLng: Double
    let endPlace: PlanGeneratePlaceDTO

    let modes: [String]
    let distance: Double
    let duration: Double
}

struct PlanGeneratePlaceDTO: Decodable {
    let platform: String
    let contentId: String
    let placeType: String
    let detailUrl: String?
    let imageUrl: String?
    let period: PlanGeneratePeriodDTO
}

struct PlanGeneratePeriodDTO: Decodable {
    let startedAt: String
    let finishedAt: String
    let duration: Int?
    let dayOrder: Int
}
