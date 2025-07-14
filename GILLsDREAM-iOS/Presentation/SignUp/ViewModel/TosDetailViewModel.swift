//
//  TosDetailViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import RxSwift
import RxCocoa

final class TosDetailViewModel: ViewModelType {
    
    struct Input {
        let closeButtonTapped: Observable<Void>
    }

    struct Output {
        let title: Driver<String>
        let content: Driver<String>
        let dismiss: Driver<Void>
    }

    var disposeBag = DisposeBag()
    private let titleRelay: BehaviorRelay<String>
    private let contentRelay: BehaviorRelay<String>
    private let dismissRelay = PublishRelay<Void>()

    init(title: String, content: String) {
        self.titleRelay = BehaviorRelay(value: title)
        self.contentRelay = BehaviorRelay(value: content)
    }

    func transform(input: Input) -> Output {
        input.closeButtonTapped
            .bind(to: dismissRelay)
            .disposed(by: disposeBag)

        return Output(
            title: titleRelay.asDriver(),
            content: contentRelay.asDriver(),
            dismiss: dismissRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
