//
//  TravelWhenViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/20/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TravelWhenViewModel {

    struct Input {
        let travelDaysInput: Observable<Int>
        let startDateInput: Observable<Date>
        let endDateInput: Observable<Date>
        let pendingButtonTapped: Observable<Void>
        let nextButtonTapped: Observable<Void>
    }

    struct Output {
        let isNextEnabled: Driver<Bool>
        let calculatedEndDate: Driver<Date>
        let calculatedStartDate: Driver<Date>
        let isPending: Driver<Bool>
        let navigateToNext: Driver<Void>
    }

    private let disposeBag = DisposeBag()

    private let isPendingRelay = BehaviorRelay<Bool>(value: false)
    private let travelDaysRelay = BehaviorRelay<Int?>(value: nil)
    private let startDateRelay = BehaviorRelay<Date?>(value: nil)
    private let endDateRelay = BehaviorRelay<Date?>(value: nil)

    private let calculatedEndDateRelay = PublishRelay<Date>()
    private let calculatedStartDateRelay = PublishRelay<Date>()
    private let isNextEnabledRelay = BehaviorRelay<Bool>(value: false)
    private let navigateToNextRelay = PublishRelay<Void>()

    func transform(input: Input) -> Output {
        // 미정 상태 토글 처리
        input.pendingButtonTapped
            .withLatestFrom(isPendingRelay)
            .map { !$0 }
            .bind(to: isPendingRelay)
            .disposed(by: disposeBag)

        input.travelDaysInput
            .do(onNext: { [self] in travelDaysRelay.accept($0) })
            .map { _ in true }
            .bind(to: isNextEnabledRelay)
            .disposed(by: disposeBag)
        
        // 시작일 변경 -> 종료일 계산
        input.startDateInput
            .do(onNext: { [weak self] date in
                guard let self = self else { return }
                self.startDateRelay.accept(date)

                if let days = self.travelDaysRelay.value {
                    guard let end = Calendar.current.date(byAdding: .day, value: days - 1, to: date) else { return }
                    self.endDateRelay.accept(end)
                    self.calculatedEndDateRelay.accept(end)
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        // 종료일 변경 -> 시작일 계산
        input.endDateInput
            .do(onNext: { [weak self] date in
                guard let self = self else { return }
                self.endDateRelay.accept(date)

                if let days = self.travelDaysRelay.value {
                    guard let start = Calendar.current.date(byAdding: .day, value: -(days - 1), to: date) else { return }
                    self.startDateRelay.accept(start)
                    self.calculatedStartDateRelay.accept(start)
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        // 여행일 변경 시 재계산
        input.travelDaysInput
            .do(onNext: { [weak self] days in
                guard let self = self else { return }
                self.travelDaysRelay.accept(days)

                if let start = self.startDateRelay.value {
                    guard let end = Calendar.current.date(byAdding: .day, value: days - 1, to: start) else { return }
                    self.endDateRelay.accept(end)
                    self.calculatedEndDateRelay.accept(end)
                } else if let end = self.endDateRelay.value {
                    guard let start = Calendar.current.date(byAdding: .day, value: -(days - 1), to: end) else { return }
                    self.startDateRelay.accept(start)
                    self.calculatedStartDateRelay.accept(start)
                }
            })
            .map { _ in true }
            .bind(to: isNextEnabledRelay)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .bind(to: navigateToNextRelay)
            .disposed(by: disposeBag)

        return Output(
            isNextEnabled: isNextEnabledRelay.asDriver(onErrorJustReturn: false),
            calculatedEndDate: calculatedEndDateRelay.asDriver(onErrorDriveWith: .empty()),
            calculatedStartDate: calculatedStartDateRelay.asDriver(onErrorDriveWith: .empty()),
            isPending: isPendingRelay.asDriver(),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    func handleDateFieldTapped(_ onCancelPending: @escaping () -> Void) {
        if isPendingRelay.value {
            isPendingRelay.accept(false)
            onCancelPending()
        }
    }
}
