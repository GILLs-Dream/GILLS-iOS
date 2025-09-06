//
//  MoodResultDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

struct MoodResultDTO: Decodable {
    let planId: Int
    let moodSummary: String
    let moodTypeList: [String]
}
