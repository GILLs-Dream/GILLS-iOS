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
            id: .init(value: dto.planId),
            moodSummary: dto.moodSummary,
            moodTypes: dto.moodTypeList
        )
    }
    
    static func toPlanID(from dto: PlanIdResultDTO) -> PlanID {
        .init(value: dto.planId)
    }
    
    static func toMinimalPlan(from dto: PlanIdResultDTO) -> Plan {
        Plan(id: dto.planId,
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
    
    static func toPlan(from dto: PlanListItemDTO) -> Plan {
        let dateRange: String? = {
            if !dto.startedAt.isEmpty && !dto.finishedAt.isEmpty {
                return "\(dto.startedAt) ~ \(dto.finishedAt)"
            } else {
                return nil
            }
        }()

        return Plan(
            id: dto.planId,
            title: dto.title,
            dateRange: dateRange,
            isPinned: false,
            imageURL: dto.mainImg,
            sortOrder: dto.planId, // TODO: 고정 로직 적용
            places: [],
            summary: ""
        )
    }
}
