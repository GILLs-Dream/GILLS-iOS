//
//  Date+.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/29/25.
//

import Foundation

extension Date {
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
