//
//  PlanMood.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/3/25.
//

struct PlanMood: Equatable {
    let id: PlanID
    let moodSummary: String
    let moodTypes: [String]
}

struct PlanID: Equatable, Hashable {
    let value: Int
}
