//
//  Place.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/22/25.
//

import Foundation

struct Place {
    let id: Int          //장소 id
    let name: String        //장소 이름
    let imageURL: String?   //장소 이미지
    var type: PlaceType     //장소 유형
    var visitDate: Date?    //장소 방문 날짜
    var checkInDate: Date?  //숙소 체크인 날짜
    var checkOutDate: Date? //숙소 체크아웃 날짜
    var dateText: String {  //장소 방문 날짜 반환
        switch type {
        case .travel:
            return visitDate?.ymdText ?? "날짜 미정"
        case .stay:
            if let checkIn = checkInDate, let checkOut = checkOutDate {
                return "\(checkIn.ymdText) - \(checkOut.ymdText)"
            } else {
                return "날짜 미정"
            }
        }
    }
}

extension Place {
    enum PlaceType {
        case travel //여행지
        case stay   //숙소
    }
}
