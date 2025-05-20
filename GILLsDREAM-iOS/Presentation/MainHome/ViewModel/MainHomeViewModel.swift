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
        let viewDidLoadTrigger: Observable<Void>
        let buttonTapped: Observable<Void>
    }

    struct Output { }

    var disposeBag = DisposeBag()

    private let navigateRelay = PublishRelay<Void>()
    private let alarmCountRelay = BehaviorRelay<Int>(value: 0)

    func transform(input: Input) -> Output {
        input.viewDidLoadTrigger
            .subscribe(onNext: { [weak self] in
                self?.fetchInitialData()
            })
            .disposed(by: disposeBag)

        input.buttonTapped
            .bind(to: navigateRelay)
            .disposed(by: disposeBag)

        return Output(
        )
    }

    private func fetchInitialData() {
        // API 연결
    }
}
