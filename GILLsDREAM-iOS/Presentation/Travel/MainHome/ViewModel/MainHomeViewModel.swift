//
//  MainHomeViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/21/25.
//

import RxSwift
import RxCocoa

final class MainHomeViewModel: ViewModelType {
    struct Input {
        let buttonTapped: Observable<Void>
    }

    struct Output {
        let navigateToRequest: Driver<Void>
    }

    var disposeBag = DisposeBag()

    private let navigateRelay = PublishRelay<Void>()
    private let alarmCountRelay = BehaviorRelay<Int>(value: 0)

    func transform(input: Input) -> Output {
        input.buttonTapped
            .bind(to: navigateRelay)
            .disposed(by: disposeBag)

        return Output(
            navigateToRequest: navigateRelay
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}
