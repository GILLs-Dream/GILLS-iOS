//
//  Date+.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/29/25.
//

import Foundation

extension Date {
    var ymdText: String {
        Date.ymdFormatter.string(from: self)
    }

    var ymdDashedText: String {
        Date.ymdDashedFormatter.string(from: self)
    }
    
    private static let ymdFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.calendar = .autoupdatingCurrent
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()
    
    private static let ymdDashedFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.calendar = .autoupdatingCurrent
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
