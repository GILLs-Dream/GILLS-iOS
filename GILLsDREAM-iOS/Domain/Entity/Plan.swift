//
//  Plan.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

struct Plan {
    let id: String
    let title: String
    let dateRange: String?
    var isPinned: Bool
    let imageURL: String? // 썸네일 이미지
    let sortOrder: Int    // 고정항목에 따른 정렬 우선순위
    let places: [PlaceResult]
    let summary: String
}

extension Plan {
    func toggledPinned() -> Plan {
        return Plan(
            id: self.id,
            title: self.title,
            dateRange: self.dateRange,
            isPinned: !self.isPinned,
            imageURL: self.imageURL,
            sortOrder: self.sortOrder,
            places: self.places,
            summary: self.summary
        )
    }
}
