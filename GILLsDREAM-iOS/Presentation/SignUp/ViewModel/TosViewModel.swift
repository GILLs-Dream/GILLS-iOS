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
        let completeSucceeded: Signal<Void>
        let completeFailed: Signal<String>
    }
    
    var disposeBag = DisposeBag()
    
    private let allRelay = BehaviorRelay<Bool>(value: false)
    private let serviceRelay = BehaviorRelay<Bool>(value: false)
    private let personalRelay = BehaviorRelay<Bool>(value: false)
    private let marketingRelay = BehaviorRelay<Bool>(value: false)
    private let navigateToNextRelay = PublishRelay<Void>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let successRelay = PublishRelay<Void>()
    private let failureRelay = PublishRelay<String>()
    
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
        
        marketingRelay
            .skip(1)
            .subscribe(onNext: { [weak self] agreed in
                self?.flow.marketingAgreement = agreed
            })
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    do {
                        _ = try await self.usecase.updateSetting(nickname: self.flow.nickname,
                                                                 profileImg: self.flow.profileImage,
                                                                 agreed: self.flow.marketingAgreement)
                        await MainActor.run { self.successRelay.accept(()) }
                    } catch {
                        await MainActor.run { self.failureRelay.accept(error.displayMessage) }
                    }
                }
                .asObservable()
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
            errorMessage: errorRelay.asSignal(),
            completeSucceeded: successRelay.asSignal(),
            completeFailed: failureRelay.asSignal()
        )
    }
    
    private func syncAllAgree() {
        let allChecked = serviceRelay.value && personalRelay.value && marketingRelay.value
        allRelay.accept(allChecked)
    }
}
