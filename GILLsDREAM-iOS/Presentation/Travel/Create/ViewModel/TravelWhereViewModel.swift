//
//  TravelWhereViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class TravelWhereViewModel {
    struct Input {
        let placeAdded: Observable<Place>
        let deleteIndexPath: Observable<IndexPath>
        let nextButtonTapped: Observable<Void>
        let prevButtonTapped: Observable<Void>
    }

    struct Output {
        let sections: Driver<[PlaceSection]>
        let isAddButtonHidden: Driver<Bool>
        let currentPage: Driver<Int>
        let currentTitleText: Driver<String>
        let navigateToNext: Driver<Void>
    }

    private let disposeBag = DisposeBag()
    private let navigateToNextRelay = PublishRelay<Void>()
    private let pageRelay = BehaviorRelay<Int>(value: 0)
    private let page1Places = BehaviorRelay<[Place]>(value: [])
    private let page2Places = BehaviorRelay<[Place]>(value: [])

    func transform(input: Input) -> Output {
        input.placeAdded
            .withLatestFrom(pageRelay) { ($0, $1) }
            .subscribe(onNext: { [weak self] place, page in
                guard let self = self else { return }
                let current = self.getCurrentPlaces(for: page)
                current.accept(current.value + [place])
            }).disposed(by: disposeBag)

        input.deleteIndexPath
            .withLatestFrom(pageRelay) { ($0, $1) }
            .subscribe(onNext: { [weak self] indexPath, page in
                guard let self = self else { return }
                let current = self.getCurrentPlaces(for: page)
                var items = current.value
                items.remove(at: indexPath.row)
                current.accept(items)
            }).disposed(by: disposeBag)

        input.nextButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.pageRelay.accept(1)
            }).disposed(by: disposeBag)

        input.prevButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.pageRelay.accept(0)
            }).disposed(by: disposeBag)

        let sections = pageRelay
            .flatMapLatest { page -> Observable<[Place]> in
                return page == 0 ? self.page1Places.asObservable() : self.page2Places.asObservable()
            }
            .map { [PlaceSection(items: $0)] }
            .asDriver(onErrorJustReturn: [])

        let isAddButtonHidden = sections
            .map { $0.first?.items.count ?? 0 >= 5 }

        let titleText = pageRelay
            .map { $0 == 0 ? "STEP 3. 생각해둔 여행지가 있다면 추가해주세요." : "STEP 3. 예약해둔 숙소가 있다면 추가해주세요." }

        return Output(
            sections: sections,
            isAddButtonHidden: isAddButtonHidden,
            currentPage: pageRelay.asDriver(),
            currentTitleText: titleText.asDriver(onErrorJustReturn: ""),
            navigateToNext: input.nextButtonTapped.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension TravelWhereViewModel {
    private func getCurrentPlaces(for page: Int) -> BehaviorRelay<[Place]> {
        return page == 0 ? page1Places : page2Places
    }
}
