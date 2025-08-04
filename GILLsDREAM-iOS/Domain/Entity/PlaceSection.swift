//
//  PlaceSection.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/5/25.
//

import RxDataSources

struct PlaceSection {
    var items: [Place]
}

extension PlaceSection: SectionModelType {
    init(original: PlaceSection, items: [Place]) {
        self = original
        self.items = items
    }
}
