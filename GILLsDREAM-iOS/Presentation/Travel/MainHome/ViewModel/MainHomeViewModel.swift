//
//  MainHomeViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/21/25.
//

import RxSwift
import RxCocoa

final class MainHomeViewModel: ViewModelType {
    private let usecase: AuthUsecase
    
    init(usecase: AuthUsecase = AuthUsecaseImpl()) {
        self.usecase = usecase
    }

    struct Input {
        let viewWillAppear: Observable<Void>
        let buttonTapped: Observable<Void>
        let homeButtonTapped: Observable<Void>
    }

    struct Output {
        let nickname: Driver<String>
        let navigateToRequest: Driver<Void>
        let navigateToHome: Driver<Void>
    }

    var disposeBag = DisposeBag()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let nicknameRelay = BehaviorRelay<String>(value: "")
    private let errorRelay = PublishRelay<String>()
    private let navigateRelay = PublishRelay<Void>()
    let navigateHomeRelay = PublishRelay<Void>()
    private let alarmCountRelay = BehaviorRelay<Int>(value: 0)

    func transform(input: Input) -> Output {
        input.viewWillAppear
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    await MainActor.run { self.loadingRelay.accept(true) }
                    defer { Task { @MainActor in self.loadingRelay.accept(false) } }
                    let me = try await self.usecase.getInfo()
                    await MainActor.run {
                        self.nicknameRelay.accept(me.nickname!)
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
        
        input.buttonTapped
            .bind(to: navigateRelay)
            .disposed(by: disposeBag)
        
        input.homeButtonTapped
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance) // 중복 탭 방지(선택)
            .bind(to: navigateHomeRelay)
            .disposed(by: disposeBag)

        return Output(
            nickname: nicknameRelay.asDriver(),
            navigateToRequest: navigateRelay.asDriver(onErrorDriveWith: .empty()),
            navigateToHome: navigateHomeRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
