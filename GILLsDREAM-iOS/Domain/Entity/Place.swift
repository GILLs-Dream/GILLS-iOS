//
//  Place.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/22/25.
//

import UIKit
import RxDataSources

struct Place: Equatable {
    let name: String
    let imageURL: UIImage
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
