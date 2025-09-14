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
    private let usecase: AuthUsecase

    init(usecase: AuthUsecase = AuthUsecaseImpl()) {
        self.usecase = usecase
    }
    
    struct Input {
        let kakaoButtonTapped: Observable<Void>
        let appleButtonTapped: Observable<Void>
    }

    struct Output {
        let showMain: Signal<Void>
        let showOnboarding: Signal<Void>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }

    var disposeBag = DisposeBag()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let showMainRelay = PublishRelay<Void>()
    private let showOnboardingRelay = PublishRelay<Void>()
    private let errorRelay = PublishRelay<String>()
    
    func transform(input: Input) -> Output {

        func route(using res: LoginResponseDTO) {
            if res.needOnboarding {
                showOnboardingRelay.accept(())
            } else {
                showMainRelay.accept(())
            }
        }

        input.kakaoButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                    let kakaoAccess = try await self.kakaoAuth.fetchAccessToken()
                    let res = try await self.usecase.loginWithKakao(accessToken: kakaoAccess)
                    await MainActor.run { route(using: res) }
                }
                .asObservable()
                .catch { [weak self] error in
                    self?.errorRelay.accept(error.displayMessage)
                    return .empty()
                }
            }
            .subscribe().disposed(by: disposeBag)

        input.appleButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                    let idtk = try await AppleAuthService.shared.fetchIdentityToken()
                    let res = try await self.usecase.loginWithApple(identityToken: idtk)
                    await MainActor.run { route(using: res) }
                }
                .asObservable()
                .catch { [weak self] error in
                    self?.errorRelay.accept(error.displayMessage)
                    return .empty()
                }
            }
            .subscribe().disposed(by: disposeBag)

        return Output(
            showMain: showMainRelay.asSignal(),
            showOnboarding: showOnboardingRelay.asSignal(),
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal()
        )
    }
}
