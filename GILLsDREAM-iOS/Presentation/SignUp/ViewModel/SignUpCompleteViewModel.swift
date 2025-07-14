//
//  SignUpCompleteViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import RxSwift
import RxCocoa

final class SignUpCompleteViewModel: ViewModelType {    
    struct Input {
        let completeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let navigateToHome: Driver<Void>
    }
    
    var disposeBag = DisposeBag()
    private let navigateToHomeRelay = PublishRelay<Void>()
    
    func transform(input: Input) -> Output {
        input.completeButtonTapped
            .bind(to: navigateToHomeRelay)
            .disposed(by: disposeBag)
        
        return Output(
            navigateToHome: navigateToHomeRelay
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}
