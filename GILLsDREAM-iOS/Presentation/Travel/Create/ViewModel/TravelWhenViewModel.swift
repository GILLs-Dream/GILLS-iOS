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
    private let usecase: PlanUsecase
    private let planId: Int
    
    init(planId: Int, usecase: PlanUsecase = PlanUsecaseImpl(repository: PlanRepositoryImpl())) {
        self.planId = planId
        self.usecase = usecase
    }
    
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
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
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
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()

    func transform(input: Input) -> Output {
        input.pendingButtonTapped
            .withLatestFrom(isPendingRelay)
            .map { !$0 }
            .bind(to: isPendingRelay)
            .disposed(by: disposeBag)

        input.travelDaysInput
            .do(onNext: { [weak self] days in
                guard let self else { return }
                self.travelDaysRelay.accept(days)

                if let start = self.startDateRelay.value {
                    if let end = Calendar.current.date(byAdding: .day, value: days - 1, to: start) {
                        self.endDateRelay.accept(end)
                        self.calculatedEndDateRelay.accept(end)
                    }
                } else if let end = self.endDateRelay.value {
                    if let start = Calendar.current.date(byAdding: .day, value: -(days - 1), to: end) {
                        self.startDateRelay.accept(start)
                        self.calculatedStartDateRelay.accept(start)
                    }
                }
            })
            .map { _ in true }
            .bind(to: isNextEnabledRelay)
            .disposed(by: disposeBag)
        
        // 시작일 변경 -> 종료일 계산
        input.startDateInput
            .do(onNext: { [weak self] date in
                guard let self else { return }
                self.startDateRelay.accept(date)

                if let days = self.travelDaysRelay.value {
                    if let end = Calendar.current.date(byAdding: .day, value: days - 1, to: date) {
                        self.endDateRelay.accept(end)
                        self.calculatedEndDateRelay.accept(end)
                    }
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        // 종료일 변경 -> 시작일 계산
        input.endDateInput
            .do(onNext: { [weak self] date in
                guard let self else { return }
                self.endDateRelay.accept(date)

                if let days = self.travelDaysRelay.value {
                    if let start = Calendar.current.date(byAdding: .day, value: -(days - 1), to: date) {
                        self.startDateRelay.accept(start)
                        self.calculatedStartDateRelay.accept(start)
                    }
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        input.nextButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }

                // 유효성
                guard let days = self.travelDaysRelay.value, days > 0 else {
                    self.errorRelay.accept("여행 기간을 입력해 주세요.")
                    return .empty()
                }

                let start = self.isPendingRelay.value ? "" : (self.startDateRelay.value?.ymdDashedText ?? "")
                let finish = self.isPendingRelay.value ? "" : (self.endDateRelay.value?.ymdDashedText ?? "")

                self.isLoadingRelay.accept(true)

                return RxAsync.run { [weak self] () async throws -> Void in
                    guard let self else { return }
                    let ok = try await self.usecase.setDuration(
                        planId: self.planId,
                        duration: days,
                        start: start,
                        finish: finish
                    )
                    if ok == false {
                        throw NSError(domain: "plan", code: -1, userInfo: [NSLocalizedDescriptionKey: "여행 기간 저장에 실패했어요."])
                    }
                }
                .asObservable()
                .do(onNext: { [weak self] in
                    self?.navigateToNextRelay.accept(())
                }, onError: { [weak self] err in
                    self?.errorRelay.accept(err.displayMessage)
                }, onDispose: { [weak self] in
                    self?.isLoadingRelay.accept(false)
                })
                .catch { _ in .empty() }
            }
            .subscribe()
            .disposed(by: disposeBag)

        return Output(
            isNextEnabled: isNextEnabledRelay.asDriver(onErrorJustReturn: false),
            calculatedEndDate: calculatedEndDateRelay.asDriver(onErrorDriveWith: .empty()),
            calculatedStartDate: calculatedStartDateRelay.asDriver(onErrorDriveWith: .empty()),
            isPending: isPendingRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal(),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension TravelWhenViewModel {
    var travelDays: Int? { travelDaysRelay.value }
    var startDate: Date? { startDateRelay.value }
    var endDate: Date? { endDateRelay.value }
    var datePending: Bool { isPendingRelay.value }

    func handleDateFieldTapped(_ onCancelPending: @escaping () -> Void) {
        if isPendingRelay.value {
            isPendingRelay.accept(false)
            onCancelPending()
        }
    }
}
