//
//  DayPlaceItem.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/11/25.
//

import UIKit
import RxDataSources

struct DayPlaceItem {
    let title: String
    let thumbnail: UIImage?
    let distanceToNextKm: Double? // 다음 장소까지의 거리(km), 마지막 item이면 nil
    let timeToNextMin: Int? // 다음 장소까지의 시간(min), 마지막 item이면 nil
}

// mock 데이터
let mockDay1PlaceItem: [DayPlaceItem] = [
    .init(title: "동궁과 월지", thumbnail: UIImage(named:"p1"), distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(title: "느좋카",     thumbnail: UIImage(named:"p2"), distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(title: "강릉 동문해변",  thumbnail: UIImage(named:"p3"), distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(title: "동궁과 월지", thumbnail: UIImage(named:"p1"), distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(title: "느좋카",     thumbnail: UIImage(named:"p2"), distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(title: "강릉 동문해변",  thumbnail: UIImage(named:"p3"), distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(title: "동궁과 월지", thumbnail: UIImage(named:"p1"), distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(title: "느좋카",     thumbnail: UIImage(named:"p2"), distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(title: "강릉 동문해변",  thumbnail: UIImage(named:"p3"), distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(title: "강릉 동문해변",  thumbnail: UIImage(named:"p4"), distanceToNextKm: nil, timeToNextMin: nil) // 마지막
]

let mockDay2PlaceItem: [DayPlaceItem] = [
    .init(title: "프로토콜", thumbnail: UIImage(named:"p1"), distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(title: "홍대기숙사",  thumbnail: UIImage(named:"p4"), distanceToNextKm: nil, timeToNextMin: nil) // 마지막
]

let mockDay3PlaceItem: [DayPlaceItem] = [
    .init(title: "성심당", thumbnail: UIImage(named:"p1"), distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(title: "상심당",  thumbnail: UIImage(named:"p4"), distanceToNextKm: nil, timeToNextMin: nil) // 마지막
]

let mockTravelData: [[DayPlaceItem]] = [
    mockDay1PlaceItem,
    mockDay2PlaceItem,
    mockDay3PlaceItem
]

let summaryText = "이번 “강릉 트로피컬 썸머 여행”은 3일간 동일한 코스로 구성되어 있으며, 매일 동굴과 원지(3.1km), 느즙카(0.1km), 강릉 동문해변을 방문하도록 계획되어 있다. 총 세 곳의 명소를 반복 방문하는 일정으로, 일정이 간결하고 동선이 짧아 여유롭고 휴양 중심의 여행에 적합하다. 전 일정이 동일하므로 여행 목적이 명확하고 반복 적인 방문을 구성된 점이 특징이다."

typealias TimelineSection = SectionModel<Void, DayPlaceItem>
