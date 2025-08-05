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
        let prevButtonTapped: Observable<Void>
        let doneButtonTapped: Observable<Void>
    }

    struct Output {
        let selectedTransport: Driver<CustomSelectableButton?>
        let selectedCategories: Driver<[CustomButton]>
        let isNextEnabled: Driver<Bool>
        let navigateToPrev: Driver<Void>
        let navigateToNext: Driver<Void>
    }

    private let disposeBag = DisposeBag()

    let selectedTransportRelay = BehaviorRelay<CustomSelectableButton?>(value: nil)
    let selectedCategoriesRelay = BehaviorRelay<[CustomButton]>(value: [])
    private let navigateToPrevRelay = PublishRelay<Void>()
    private let navigateToNextRelay = PublishRelay<Void>()

    func transform(input: Input) -> Output {
        input.transportTapped
            .map { [weak self] tapped in
                return self?.selectedTransportRelay.value == tapped ? nil : tapped
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
        
        input.prevButtonTapped
            .bind(to: navigateToPrevRelay)
            .disposed(by: disposeBag)

        input.doneButtonTapped
            .bind(to: navigateToNextRelay)
            .disposed(by: disposeBag)

        let isNextEnabled = Observable
            .combineLatest(selectedTransportRelay, selectedCategoriesRelay)
            .map { $0 != nil && !$1.isEmpty }

        return Output(
            selectedTransport: selectedTransportRelay.asDriver(onErrorJustReturn: nil),
            selectedCategories: selectedCategoriesRelay.asDriver(onErrorJustReturn: []),
            isNextEnabled: isNextEnabled.asDriver(onErrorJustReturn: false),
            navigateToPrev: navigateToPrevRelay.asDriver(onErrorDriveWith: .empty()),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension TravelHowViewModel {
    // MARK: Output accessors
    var transportation: String? {
        return selectedTransportRelay.value?.title(for: .normal)
    }

    var categories: [String]? {
        return selectedCategoriesRelay.value.map { $0.title(for: .normal) ?? "" }
    }
}
