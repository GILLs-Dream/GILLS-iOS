//
//  Mkc.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/28/25.
//

// mock 데이터
let mockDay1PlaceItem: [PlaceResult] = [
    .init(id: "1", title: "동궁과 월지", imageURL: "", distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(id: "1", title: "느좋카",     imageURL: "", distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(id: "1", title: "강릉 동문해변",  imageURL: "", distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(id: "1", title: "동궁과 월지", imageURL: "", distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(id: "1", title: "느좋카",     imageURL: "", distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(id: "1", title: "강릉 동문해변",  imageURL: "", distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(id: "1", title: "동궁과 월지", imageURL: "", distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(id: "1", title: "느좋카",     imageURL: "", distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(id: "1", title: "강릉 동문해변",  imageURL: "", distanceToNextKm: 0.1, timeToNextMin: 10),
    .init(id: "1", title: "강릉 동문해변",  imageURL: "", distanceToNextKm: nil, timeToNextMin: nil) // 마지막
]

let mockDay2PlaceItem: [PlaceResult] = [
    .init(id: "1", title: "프로토콜", imageURL: "", distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(id: "1", title: "홍대기숙사",  imageURL: "", distanceToNextKm: nil, timeToNextMin: nil) // 마지막
]

let mockDay3PlaceItem: [PlaceResult] = [
    .init(id: "1", title: "성심당", imageURL: "", distanceToNextKm: 3.1, timeToNextMin: 10),
    .init(id: "1", title: "상심당",  imageURL: "", distanceToNextKm: nil, timeToNextMin: nil) // 마지막
]

let mockTravelData: [[PlaceResult]] = [
    mockDay1PlaceItem,
    mockDay2PlaceItem,
    mockDay3PlaceItem
]

let summaryText = "이번 “강릉 트로피컬 썸머 여행”은 3일간 동일한 코스로 구성되어 있으며, 매일 동굴과 원지(3.1km), 느즙카(0.1km), 강릉 동문해변을 방문하도록 계획되어 있다. 총 세 곳의 명소를 반복 방문하는 일정으로, 일정이 간결하고 동선이 짧아 여유롭고 휴양 중심의 여행에 적합하다. 전 일정이 동일하므로 여행 목적이 명확하고 반복 적인 방문을 구성된 점이 특징이다."

let myPlanDummy = [
    Plan(id: "1", title: "깔루아 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: true, imageURL: nil, sortOrder: 0, places: [], summary: summaryText),
    Plan(id: "2", title: "길순이 경주여행", dateRange: nil, isPinned: true, imageURL: nil, sortOrder: 1, places: [], summary: summaryText),
    Plan(id: "3", title: "닐순이 경주여행", dateRange: nil, isPinned: true, imageURL: nil, sortOrder: 2, places: [], summary: summaryText),
    Plan(id: "4", title: "딜순이 경주여행", dateRange: nil, isPinned: true, imageURL: nil, sortOrder: 3, places: [], summary: summaryText),
    Plan(id: "5", title: "릴순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 4, places: [], summary: summaryText),
    Plan(id: "6", title: "밀순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 5, places: [], summary: summaryText),
    Plan(id: "7", title: "빌순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 6, places: [], summary: summaryText),
    Plan(id: "8", title: "실순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 7, places: [], summary: summaryText),
    Plan(id: "9", title: "일순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 8, places: [], summary: summaryText),
]
