//
//  TravelRequestViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelRequestViewModel {

    struct Input {
        let textInput: Observable<String>
        let sendButtonTapped: Observable<Void>
    }

    struct Output {
        let isSendEnabled: Driver<Bool>
        let navigateToNext: Driver<Void>
    }

    let disposeBag = DisposeBag()
    private let travelTextRelay = BehaviorRelay<String>(value: "")
    private let navigateToNextRelay = PublishRelay<Void>()

    func transform(input: Input) -> Output {
        input.textInput
            .bind(to: travelTextRelay)
            .disposed(by: disposeBag)

        input.sendButtonTapped
            .withLatestFrom(travelTextRelay)
            .do(onNext: { text in
                print(text)
            })
            .map { _ in }
            .bind(to: navigateToNextRelay)
            .disposed(by: disposeBag)

        return Output(
            isSendEnabled: travelTextRelay
                .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false),

            navigateToNext: navigateToNextRelay
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}
