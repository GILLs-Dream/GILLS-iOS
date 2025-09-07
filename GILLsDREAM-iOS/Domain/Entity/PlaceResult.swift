//
//  DayPlaceItem.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/11/25.
//

struct PlaceResult {
    let id: Int
    let title: String
    let imageURL: String?
    let distanceToNextKm: Double? // 다음 장소까지의 거리(km), 마지막 item이면 nil
    let timeToNextMin: Int? // 다음 장소까지의 시간(min), 마지막 item이면 nil
}
