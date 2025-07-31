//
//  Place.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/22/25.
//

import UIKit
import RxDataSources

enum PlaceType {
    case travel //여행지
    case stay //숙소
}

struct Place {
    let name: String
    let imageURL: UIImage?
    var type: PlaceType
    
    var visitDate: Date?
    var checkInDate: Date?
    var checkOutDate: Date?
}

struct PlaceSection {
    var items: [Place]
}

extension PlaceSection: SectionModelType {
    init(original: PlaceSection, items: [Place]) {
        self = original
        self.items = items
    }
}

extension Place {
    var dateText: String {
        switch type {
        case .travel:
            return visitDate?.formatted("yyyy/MM/dd") ?? "날짜 미정"
        case .stay:
            if let checkIn = checkInDate, let checkOut = checkOutDate {
                return "\(checkIn.formatted("yyyy/MM/dd")) - \(checkOut.formatted("yyyy/MM/dd"))"
            } else {
                return "날짜 미정"
            }
        }
    }
}
