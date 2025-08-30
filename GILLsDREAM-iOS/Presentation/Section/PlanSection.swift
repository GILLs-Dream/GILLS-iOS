//
//  PlanSectionModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/5/25.
//

import RxDataSources

struct PlanSection {
    var items: [Plan]
}

extension PlanSection: SectionModelType {
    typealias Item = Plan

    init(original: PlanSection, items: [Plan]) {
        self = original
        self.items = items
    }
}
