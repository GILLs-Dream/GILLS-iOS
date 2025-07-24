//
//  TravelHowViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/23/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TravelHowViewModel {
    struct Input {
        let transportTapped: Observable<CustomSelectableButton>
        let categoryTapped: Observable<CustomButton>
        let nextButtonTapped: Observable<Void>
    }

    struct Output {
        let selectedTransport: Driver<CustomSelectableButton?>
        let selectedCategories: Driver<[CustomButton]>
        let isNextEnabled: Driver<Bool>
        let navigateToNext: Driver<Void>
    }

    private let disposeBag = DisposeBag()

    private let selectedTransportRelay = BehaviorRelay<CustomSelectableButton?>(value: nil)
    private let selectedCategoriesRelay = BehaviorRelay<[CustomButton]>(value: [])
    private let navigateToNextRelay = PublishRelay<Void>()

    func transform(input: Input) -> Output {
        input.transportTapped
            .withLatestFrom(selectedTransportRelay) { new, current -> CustomSelectableButton? in
                return current == new ? new : new // 변경이 있으면 갱신
            }
            .bind(to: selectedTransportRelay)
            .disposed(by: disposeBag)

        input.categoryTapped
            .withLatestFrom(selectedCategoriesRelay) { tapped, current in
                var updated = current
                if let index = updated.firstIndex(of: tapped) {
                    updated.remove(at: index)
                } else {
                    updated.append(tapped)
                }
                return updated
            }
            .bind(to: selectedCategoriesRelay)
            .disposed(by: disposeBag)

        input.nextButtonTapped
            .bind(to: navigateToNextRelay)
            .disposed(by: disposeBag)

        let isNextEnabled = Observable
            .combineLatest(selectedTransportRelay, selectedCategoriesRelay)
            .map { $0 != nil && !$1.isEmpty }

        return Output(
            selectedTransport: selectedTransportRelay.asDriver(onErrorJustReturn: nil),
            selectedCategories: selectedCategoriesRelay.asDriver(onErrorJustReturn: []),
            isNextEnabled: isNextEnabled.asDriver(onErrorJustReturn: false),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
