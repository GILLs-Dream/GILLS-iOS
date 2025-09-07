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
    // MARK: Create
    var planId: Int?
    var region: String = ""
    var moodSummary: String = ""
    
    // MARK: When
    let travelDays = BehaviorRelay<Int?>(value: nil) //필수
    let startDate = BehaviorRelay<Date?>(value: nil) //선택
    let endDate   = BehaviorRelay<Date?>(value: nil) //선택
    let datePending = BehaviorRelay<Bool>(value: false) //필수 (default값 = false)

    // MARK: Who
    let peopleCount  = BehaviorRelay<Int?>(value: nil) //필수
    let peopleDetail = BehaviorRelay<String?>(value: nil) //선택

    // MARK: Where
    let travelPlaces = BehaviorRelay<[Place]?>(value: []) //선택
    let stayPlaces   = BehaviorRelay<[Place]?>(value: []) //선택

    // MARK: How
    let transportation = BehaviorRelay<String?>(value: nil) //필수
    let categories     = BehaviorRelay<[String]?>(value: []) //필수

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
        (transportation.value?.isEmpty == false) && (categories.value?.isEmpty == false)
    }
}
