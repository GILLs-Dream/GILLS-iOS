//
//  TravelResultViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/6/25.
//

import RxSwift
import RxCocoa
import RxDataSources

typealias DaySection = SectionModel<Void, Int>  // 아이템 = 인덱스(Int)

final class TravelResultViewModel {
    struct Input {
        /// 아이템 인덱스 목록 (예: [0, 1, 2, 3]  // 마지막 3이 '요약' 용)
        let items: Observable<[Int]>
        /// 사용자 선택 인덱스
        let didSelectIndex: Observable<Int>
    }
    struct Output {
        let sections: Driver<[DaySection]>  // 각 아이템은 Int 인덱스
        let selectedIndex: Driver<Int>      // 현재 선택
    }

    private let disposeBag = DisposeBag()
    private let selectedIndexRelay = BehaviorRelay<Int>(value: 0)

    func transform(input: Input) -> Output {
        input.didSelectIndex
            .bind(to: selectedIndexRelay)
            .disposed(by: disposeBag)

        let sections = input.items
            .map { [DaySection(model: (), items: $0)] }
            .asDriver(onErrorJustReturn: [])

        return Output(
            sections: sections,
            selectedIndex: selectedIndexRelay.asDriver()
        )
    }
}
