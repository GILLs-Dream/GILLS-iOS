//
//  TosViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import RxSwift
import RxCocoa

final class TosViewModel: ViewModelType {
    
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
    }

    var disposeBag = DisposeBag()

    private let allRelay = BehaviorRelay<Bool>(value: false)
    private let serviceRelay = BehaviorRelay<Bool>(value: false)
    private let personalRelay = BehaviorRelay<Bool>(value: false)
    private let marketingRelay = BehaviorRelay<Bool>(value: false)
    private let navigateToNextRelay = PublishRelay<Void>()

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
            .bind(to: navigateToNextRelay)
            .disposed(by: disposeBag)

        let isNextEnabled = Observable
            .combineLatest(allRelay, serviceRelay, personalRelay)
            .map { all, service, personal in
                return all || (service && personal)
            }

        return Output(
            allChecked: allRelay
                .asDriver(onErrorJustReturn: false),
            serviceChecked: serviceRelay
                .asDriver(onErrorJustReturn: false),
            personalChecked: personalRelay
                .asDriver(onErrorJustReturn: false),
            marketingChecked: marketingRelay
                .asDriver(onErrorJustReturn: false),
            isNextButtonEnabled: isNextEnabled
                .asDriver(onErrorJustReturn: false),
            navigateToNext: navigateToNextRelay
                .asDriver(onErrorDriveWith: .empty())
        )
    }

    private func syncAllAgree() {
        let allChecked = serviceRelay.value && personalRelay.value && marketingRelay.value
        allRelay.accept(allChecked)
    }
}
