//
//  VideosResultDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//


struct VideosResultDTO: Decodable {
    let planId: Int
    let recommendedList: [String]?
}
