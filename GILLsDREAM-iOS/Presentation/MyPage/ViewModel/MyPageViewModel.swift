//
//  MyPageViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import RxSwift
import RxCocoa

final class MyPageViewModel {
    private let usecase: AuthUsecase
    
    init(usecase: AuthUsecase = AuthUsecaseImpl()) {
        self.usecase = usecase
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let serviceTapped: Observable<Void>
        let withdrawTapped: Observable<Void>
        let logoutTapped: Observable<Void>
        let confirmLogout: Observable<Void>
        let confirmWithdraw: Observable<Void>
    }
    
    struct Output {
        let profile: Driver<String>
        let nickname: Driver<String>
        let email: Driver<String>
        let showServiceTerms: Signal<Void>
        let showWithdrawModal: Signal<Void>
        let showLogoutModal: Signal<Void>
        let isLoading: Driver<Bool>
        let logoutSucceeded: Signal<Void>
        let withdrawSucceeded: Signal<Void>
        let errorMessage: Signal<String>
    }

    private let disposeBag = DisposeBag()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let showServiceRelay = PublishRelay<Void>()
    private let showWithdrawRelay = PublishRelay<Void>()
    private let showLogoutRelay = PublishRelay<Void>()
    private let logoutOKRelay = PublishRelay<Void>()
    private let withdrawOKRelay = PublishRelay<Void>()
    private let errorRelay = PublishRelay<String>()
    private let profileRelay = BehaviorRelay<String>(value: "")
    private let nicknameRelay = BehaviorRelay<String>(value: "")
    private let emailRelay = BehaviorRelay<String>(value: "")
    
    func transform(input: Input) -> Output {
        input.serviceTapped.bind(to: showServiceRelay).disposed(by: disposeBag)
        input.withdrawTapped.bind(to: showWithdrawRelay).disposed(by: disposeBag)
        input.logoutTapped.bind(to: showLogoutRelay).disposed(by: disposeBag)
        
        input.viewWillAppear
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    await MainActor.run { self.loadingRelay.accept(true) }
                    defer { Task { @MainActor in self.loadingRelay.accept(false) } }
                    let me = try await self.usecase.getInfo()
                    await MainActor.run {
                        self.profileRelay.accept(me.profile ?? "")
                        self.nicknameRelay.accept(me.nickname)
                        self.emailRelay.accept(me.email)
                        print("👉 profile url =", me.profile ?? "nil")
                    }
                }
                .asObservable()
                .catch { [weak self] error in
                    self?.errorRelay.accept(error.displayMessage)
                    return .empty()
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        // 로그아웃
        input.confirmLogout
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    await MainActor.run { self.loadingRelay.accept(true) }
                    defer { Task { @MainActor in self.loadingRelay.accept(false) } }
                    try await self.usecase.logout()
                    await MainActor.run { self.logoutOKRelay.accept(()) }
                }
                .asObservable()
                .catch { [weak self] err in
                    self?.errorRelay.accept(err.displayMessage)
                    return .empty()
                }
            }
            .subscribe().disposed(by: disposeBag)

        // 회원탈퇴
        input.confirmWithdraw
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    await MainActor.run { self.loadingRelay.accept(true) }
                    defer { Task { @MainActor in self.loadingRelay.accept(false) } }
                    try await self.usecase.deleteAccount()
                    await MainActor.run { self.withdrawOKRelay.accept(()) }
                }
                .asObservable()
                .catch { [weak self] err in
                    self?.errorRelay.accept(err.displayMessage)
                    return .empty()
                }
            }
            .subscribe().disposed(by: disposeBag)

        return Output(
            profile: profileRelay.asDriver(),
            nickname: nicknameRelay.asDriver(),
            email: emailRelay.asDriver(),
            showServiceTerms: showServiceRelay.asSignal(),
            showWithdrawModal: showWithdrawRelay.asSignal(),
            showLogoutModal: showLogoutRelay.asSignal(),
            isLoading: loadingRelay.asDriver(),
            logoutSucceeded: logoutOKRelay.asSignal(),
            withdrawSucceeded: withdrawOKRelay.asSignal(),
            errorMessage: errorRelay.asSignal()
        )
    }
}
