//
//  PlanMapper.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/3/25.
//

import Foundation

enum PlanMapper {
    static func toPlanMood(from dto: MoodResultDTO) -> PlanMood {
        PlanMood(
            id: .init(value: String(dto.planId)),
            moodSummary: dto.moodSummary,
            moodTypes: dto.moodTypeList
        )
    }
    
    static func toPlanID(from dto: PlanIdResultDTO) -> PlanID {
        .init(value: String(dto.planId))
    }
    
    static func toMinimalPlan(from dto: PlanIdResultDTO) -> Plan {
        Plan(id: String(dto.planId),
             title: "",
             dateRange: nil,
             isPinned: false,
             imageURL: nil,
             sortOrder: 0,
             places: [],
             summary: "")
    }
    
    static func toPlanMoods(from list: [MoodResultDTO]) -> [PlanMood] {
        list.map { toPlanMood(from: $0) }
    }
}
