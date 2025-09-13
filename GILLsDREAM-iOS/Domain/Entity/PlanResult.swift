//
//  PlanResult.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/12/25.
//

struct PlanResult {
    let title: String
    let planId: Int
    let duration: Int
    let perDayList: [PlanPerDay]
}

struct PlanPerDay {
    let dayNum: Int
    let from: PlanPlace
    let routes: [PlanRoute]
}

struct PlanRoute {
    let cnt: Int
    let to: PlanPlace
    let distance: Int
    let time: Int
}

struct PlanPlace {
    let placeId: Int
    let name: String
    let mainImg: String
}

struct PlanSummary {
    let title: String
    let summary: String
}

enum TravelTimelineRow {
    case start(PlanPlace) // 첫 셀
    case route(PlanRoute) // 이후 셀들 (이전→현재 거리/시간 표시)
}
