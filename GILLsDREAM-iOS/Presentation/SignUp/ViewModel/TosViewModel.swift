//
//  TosViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import RxSwift
import RxCocoa

final class TosViewModel: ViewModelType {
    private let usecase: AuthUsecase
    private let flow: SignupFlowViewModel

    init(flowmodel: SignupFlowViewModel,
         usecase: AuthUsecase = AuthUsecaseImpl()) {
        self.flow = flowmodel
        self.usecase = usecase
    }
    
    struct Input {
        let allAgreeTapped: Observable<Void>
        let serviceTapped: Observable<Void>
        let personalTapped: Observable<Void>
        let marketingTapped: Observable<Void>
        let nextButtonTapped: Observable<Void>
    }

    struct Output {
        let allChecked: Driver<Bool>
        let serviceChecked: Driver<Bool>
        let personalChecked: Driver<Bool>
        let marketingChecked: Driver<Bool>
        let isNextButtonEnabled: Driver<Bool>
        let navigateToNext: Driver<Void>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }

    var disposeBag = DisposeBag()

    private let allRelay = BehaviorRelay<Bool>(value: false)
    private let serviceRelay = BehaviorRelay<Bool>(value: false)
    private let personalRelay = BehaviorRelay<Bool>(value: false)
    private let marketingRelay = BehaviorRelay<Bool>(value: false)
    private let navigateToNextRelay = PublishRelay<Void>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()

    func transform(input: Input) -> Output {
        // 전체 동의 눌렀을 때 모두 toggle
        input.allAgreeTapped
            .withLatestFrom(allRelay)
            .map { !$0 }
            .do(onNext: { [weak self] newValue in
                self?.allRelay.accept(newValue)
                self?.serviceRelay.accept(newValue)
                self?.personalRelay.accept(newValue)
                self?.marketingRelay.accept(newValue)
            })
            .subscribe()
            .disposed(by: disposeBag)

        // 개별 항목 누르면 toggle
        input.serviceTapped
            .withLatestFrom(serviceRelay)
            .map { !$0 }
            .do(onNext: { [weak self] newValue in
                self?.serviceRelay.accept(newValue)
                self?.syncAllAgree()
            })
            .subscribe()
            .disposed(by: disposeBag)

        input.personalTapped
            .withLatestFrom(personalRelay)
            .map { !$0 }
            .do(onNext: { [weak self] newValue in
                self?.personalRelay.accept(newValue)
                self?.syncAllAgree()
            })
            .subscribe()
            .disposed(by: disposeBag)

        input.marketingTapped
            .withLatestFrom(marketingRelay)
            .map { !$0 }
            .do(onNext: { [weak self] newValue in
                self?.marketingRelay.accept(newValue)
                self?.syncAllAgree()
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                    self.flow.marketingAgreement = self.marketingRelay.value
                    self.navigateToNextRelay.accept(()) // TODO: 연결되면 삭제
                    //TODO: 백엔드 api 수정 후 연결
//                    try await self.usecase.updateSetting(
//                        nickname: self.flow.nickname,
//                        profileImg: self.flow.profileImage,
//                        agreed: self.flow.marketingAgreement
//                    )
//                    await MainActor.run { self.navigateToNextRelay.accept(()) }
                }
                
                .asObservable()
                .catch { [weak self] error in
                    self?.errorRelay.accept(error.displayMessage)
                    return .empty()
                }
            }
            .subscribe()
            .disposed(by: disposeBag)

        let isNextEnabled = Observable
            .combineLatest(allRelay, serviceRelay, personalRelay)
            .map { all, service, personal in
                all || (service && personal)
            }

        return Output(
            allChecked: allRelay.asDriver(onErrorJustReturn: false),
            serviceChecked: serviceRelay.asDriver(onErrorJustReturn: false),
            personalChecked: personalRelay.asDriver(onErrorJustReturn: false),
            marketingChecked: marketingRelay.asDriver(onErrorJustReturn: false),
            isNextButtonEnabled: isNextEnabled.asDriver(onErrorJustReturn: false),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty()),
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal()
        )
    }

    private func syncAllAgree() {
        let allChecked = serviceRelay.value && personalRelay.value && marketingRelay.value
        allRelay.accept(allChecked)
    }
}
