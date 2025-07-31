//
//  TravelCreateFlowViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TravelRequestFlowViewModel {
    // MARK: When
    let travelDays = BehaviorRelay<Int?>(value: nil)
    let startDate = BehaviorRelay<Date?>(value: nil)
    let endDate   = BehaviorRelay<Date?>(value: nil)
    let datePending = BehaviorRelay<Bool?>(value: nil)

    // MARK: Who
    let peopleCount  = BehaviorRelay<Int?>(value: nil)
    let peopleDetail = BehaviorRelay<String>(value: "")

    // MARK: Where
    let travelPlaces = BehaviorRelay<[Place]>(value: [])
    let stayPlaces   = BehaviorRelay<[Place]>(value: [])

    // MARK: How
    let transportation = BehaviorRelay<String?>(value: nil)
    let categories     = BehaviorRelay<[String]>(value: [])

    // MARK: Validation
    var isWhenValid: Bool {
        guard let days = travelDays.value else { return false }
        return days > 0
    }

    var isWhoValid: Bool {
        guard let count = peopleCount.value else { return false }
        return count > 0
    }

    var isHowValid: Bool {
        (transportation.value?.isEmpty == false) && (categories.value.isEmpty == false)
    }
}
