//
//  TravelWhoViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TravelWhoViewModel {
    // MARK: DI
    private let usecase: PlanUsecase
    private let planId: Int

    init(planId: Int,
         usecase: PlanUsecase = PlanUsecaseImpl(repository: PlanRepositoryImpl())) {
        self.planId = planId
        self.usecase = usecase
    }
    
    struct Input {
        let peopleCountInput: Observable<Int>
        let peopleDetailInput: Observable<String>
        let prevButtonTapped: Observable<Void>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isNextEnabled: Driver<Bool>
        let navigateToPrev: Driver<Void>
        let navigateToNext: Driver<Void>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }
    
    private let disposeBag = DisposeBag()
    
    private let peopleCountRelay = BehaviorRelay<Int?>(value: nil)
    private let peopleDetailRelay = BehaviorRelay<String?>(value: nil)
    private let isNextEnabledRelay = BehaviorRelay<Bool>(value: false)
    private let navigateToPrevRelay = PublishRelay<Void>()
    private let navigateToNextRelay = PublishRelay<Void>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    
    func transform(input: Input) -> Output {
        
        input.peopleCountInput
            .do(onNext: { [weak self] pax in
                self?.peopleCountRelay.accept(pax)
            })
            .map { _ in true }
            .bind(to: isNextEnabledRelay)
            .disposed(by: disposeBag)
        
        input.peopleDetailInput
            .bind(to: peopleDetailRelay)
            .disposed(by: disposeBag)
        
        input.prevButtonTapped
            .bind(to: navigateToPrevRelay)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(Observable.combineLatest(peopleCountRelay, peopleDetailRelay))
            .flatMapLatest { [weak self] (paxOpt, detailOpt) -> Observable<Void> in
                guard let self = self else { return .empty() }
                guard let pax = paxOpt, pax > 0 else {
                    self.errorRelay.accept("인원 수를 입력해 주세요.")
                    return .empty()
                }

                let companion = (detailOpt ?? "")
                return RxAsync.run { [weak self] () async throws -> Void in
                    guard let self = self else { return }
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                    let ok = try await self.usecase.setCompanion(
                        planId: self.planId,
                        party: pax,
                        companion: companion
                    )
                    if ok == false {
                        throw NSError(domain: "plan", code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "동행 정보 저장에 실패했어요."])
                    }
                    await MainActor.run {
                        self.navigateToNextRelay.accept(())
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
        
        return Output(
            isNextEnabled: isNextEnabledRelay.asDriver(onErrorJustReturn: false),
            navigateToPrev: navigateToPrevRelay.asDriver(onErrorDriveWith: .empty()),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty()),
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal()
        )
    }
}

extension TravelWhoViewModel {
    // MARK: Output accessors
    var peopleCount: Int? {
        return peopleCountRelay.value
    }
    
    var peopleDetail: String? {
        return peopleDetailRelay.value
    }
}
