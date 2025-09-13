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
            summary: ""
        )
    }
    
    static func toPlanResult(from dto: PlanResultResponseDTO) -> PlanResult {
        let perDayList = dto.planPerDayDtoList.map { dayDTO in
            let from = PlanPlace(
                placeId: dayDTO.from.placeId,
                name: dayDTO.from.name,
                mainImg: dayDTO.from.mainImg
            )
            
            let routes = dayDTO.routeDtoList.map { routeDTO in
                let to = PlanPlace(
                    placeId: routeDTO.to.placeId,
                    name: routeDTO.to.name,
                    mainImg: routeDTO.to.mainImg
                )
                return PlanRoute(
                    cnt: routeDTO.cnt,
                    to: to,
                    distance: Int(routeDTO.distance),
                    time: Int(routeDTO.time)
                )
            }
            
            return PlanPerDay(
                dayNum: dayDTO.dayNum,
                from: from,
                routes: routes
            )
        }
        
        return PlanResult(
            title: dto.title,
            planId: dto.planId,
            duration: dto.duration,
            perDayList: perDayList
        )
    }
    
    static func toPlanSummary(from dto: PlanSummaryResponseDTO) -> PlanSummary {
        PlanSummary(title: dto.title, summary: dto.summary)
    }
}
