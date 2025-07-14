//
//  InitialViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 6/3/25.
//

import RxSwift
import RxCocoa

final class InitialViewModel: ViewModelType {
    struct Input {
        let kakaoButtonTapped: Observable<Void>
        let appleButtonTapped: Observable<Void>
    }

    struct Output {
        let navigateToKakaoSignUp: Driver<Void>
        let navigateToAppleSignUp: Driver<Void>
    }

    var disposeBag = DisposeBag()
    private let navigateToKakaoSignUpRelay = PublishRelay<Void>()
    private let navigateToAppleSignUpRelay = PublishRelay<Void>()
    
    func transform(input: Input) -> Output {
        input.kakaoButtonTapped
            .bind(to: navigateToKakaoSignUpRelay)
            .disposed(by: disposeBag)

        input.appleButtonTapped
            .bind(to: navigateToAppleSignUpRelay)
            .disposed(by: disposeBag)

        return Output(
            navigateToKakaoSignUp: navigateToKakaoSignUpRelay.asDriver(onErrorDriveWith: .empty()),
            navigateToAppleSignUp: navigateToAppleSignUpRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
