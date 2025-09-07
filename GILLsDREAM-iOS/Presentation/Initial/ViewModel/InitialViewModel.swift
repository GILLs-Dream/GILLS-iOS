//
//  InitialViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 6/3/25.
//

import RxSwift
import RxCocoa

final class InitialViewModel: ViewModelType {
    private let kakaoAuth = KakaoAuthService()
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
    }
    
    struct Input {
        let kakaoButtonTapped: Observable<Void>
        let appleButtonTapped: Observable<Void>
    }

    struct Output {
        let navigateToKakaoSignUp: Driver<Void>
        let navigateToAppleSignUp: Driver<Void>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }

    var disposeBag = DisposeBag()
    private let navigateToKakaoSignUpRelay = PublishRelay<Void>()
    private let navigateToAppleSignUpRelay = PublishRelay<Void>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    
    func transform(input: Input) -> Output {
        input.kakaoButtonTapped
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)  // 중복 탭 방지
            .flatMapLatest { [weak self] _ -> Observable<Session> in
                guard let self else { return .empty() }
                self.isLoadingRelay.accept(true)

                // Kakao SDK 토큰 -> 서버 로그인
                let single: Single<Session> = RxAsync.run {
                    let code = try await self.kakaoAuth.fetchAuthCode()
                    return try await self.authRepository.kakaoLogin(code: code)
                }

                return single
                    .do(onSuccess: { [weak self] _ in
                        self?.navigateToKakaoSignUpRelay.accept(())
                    }, onError: { [weak self] error in
                        self?.errorRelay.accept((error as? NetworkError)?.message ?? "")
                    }, onDispose: { [weak self] in
                        self?.isLoadingRelay.accept(false)
                    })
                    .asObservable()
                    .catch { _ in Observable<Session>.empty() }
            }
            .subscribe()
            .disposed(by: disposeBag)

        input.appleButtonTapped
            .bind(to: navigateToAppleSignUpRelay)
            .disposed(by: disposeBag)

        return Output(
            navigateToKakaoSignUp: navigateToKakaoSignUpRelay.asDriver(onErrorDriveWith: .empty()),
            navigateToAppleSignUp: navigateToAppleSignUpRelay.asDriver(onErrorDriveWith: .empty()),
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal()
        )
    }
}
