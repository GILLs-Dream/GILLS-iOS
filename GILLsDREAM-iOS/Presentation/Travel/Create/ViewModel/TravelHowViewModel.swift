//
//  TravelHowViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelHowViewModel {
    private let usecase: PlanUsecase
    private let planId: Int
    
    init(planId: Int, usecase: PlanUsecase = PlanUsecaseImpl(repository: PlanRepositoryImpl())) {
        self.planId = planId
        self.usecase = usecase
    }

    struct Input {
        let transportTapped: Observable<CustomSelectableButton>
        let categoryTapped: Observable<CustomButton>
        let prevButtonTapped: Observable<Void>
        let doneButtonTapped: Observable<Void>
    }

    struct Output {
        let selectedTransport: Driver<CustomSelectableButton?>
        let selectedCategories: Driver<[CustomButton]>
        let isNextEnabled: Driver<Bool>
        let navigateToPrev: Driver<Void>
        let navigateToNext: Driver<Void>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
        let showGeneratedConfirmModal: Signal<Void>
        let showGenerationFailed: Signal<Void>
    }

    private let disposeBag = DisposeBag()

    let selectedTransportRelay = BehaviorRelay<CustomSelectableButton?>(value: nil)
    let selectedCategoriesRelay = BehaviorRelay<[CustomButton]>(value: [])
    private let navigateToPrevRelay = PublishRelay<Void>()
    let navigateToNextRelay = PublishRelay<Void>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let showGeneratedConfirmModalRelay = PublishRelay<Void>()
    private let showGenerationFailedRelay = PublishRelay<Void>()

    func transform(input: Input) -> Output {
        input.transportTapped
            .map { [weak self] tapped in
                return self?.selectedTransportRelay.value == tapped ? nil : tapped
            }
            .bind(to: selectedTransportRelay)
            .disposed(by: disposeBag)

        input.categoryTapped
            .withLatestFrom(selectedCategoriesRelay) { tapped, current in
                var updated = current
                if let index = updated.firstIndex(of: tapped) {
                    updated.remove(at: index)
                } else {
                    updated.append(tapped)
                }
                return updated
            }
            .bind(to: selectedCategoriesRelay)
            .disposed(by: disposeBag)
        
        input.prevButtonTapped
            .bind(to: navigateToPrevRelay)
            .disposed(by: disposeBag)

        input.doneButtonTapped
            .withLatestFrom(Observable.combineLatest(selectedTransportRelay, selectedCategoriesRelay))
            .flatMapLatest { [weak self] (transportBtn, categoryBtns) -> Observable<Void> in
                guard let self else {
                    return .empty()
                }

                guard let transport = (transportBtn as? UIButton)?.title(for: .normal),
                      categoryBtns.isEmpty == false,
                      self.planId > 0 else {
                    self.errorRelay.accept("교통수단과 카테고리를 선택해 주세요.")
                    return .empty()
                }

                let categories = categoryBtns.compactMap { ($0 as? UIButton)?.title(for: .normal) }
                
                return RxAsync.run { [weak self] () async throws -> Void in
                    guard let self else { return }
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                    do {
                        let saved = try await self.usecase.setStyle(
                            planId: self.planId,
                            transport: transport,
                            categories: categories
                        )
                        if saved == false {
                            throw NSError(
                                domain: "plan",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "여행 스타일 저장에 실패했어요."]
                            )
                        }
                    } catch {
                        throw error
                    }

                    // 2) 생성 트리거
                    do {
                        try await self.usecase.generatePlan(planId: self.planId)
                        print("✅ [API] generatePlan done")
                    } catch {
                        print("❌ [API] generatePlan error:", error)
                        throw error
                    }

                    // 3) 생성본 조회
                    let generated: PlanResult
                    do {
                        generated = try await self.usecase.getGeneratedPlan(planId: self.planId)
                        print("✅ [API] getGeneratedPlan days=\(generated.perDayList.count)")
                        for day in generated.perDayList {
                            print("   • day=\(day.dayNum) routes=\(day.routes.count)")
                        }
                    } catch {
                        print("❌ [API] getGeneratedPlan error:", error)
                        throw error
                    // 4) 실패/성공 판정
                    let isAllEmpty = generated.perDayList.isEmpty
                        || generated.perDayList.allSatisfy { $0.routes.isEmpty }
                    print("🔍 [HOW] isAllEmpty=\(isAllEmpty)")

                    await MainActor.run {
                        isAllEmpty ? self.showGenerationFailedRelay.accept(())
                        : self.showGeneratedConfirmModalRelay.accept(())
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

        let isNextEnabled = Observable
            .combineLatest(selectedTransportRelay, selectedCategoriesRelay)
            .map { $0 != nil && !$1.isEmpty }

        return Output(
            selectedTransport: selectedTransportRelay.asDriver(onErrorJustReturn: nil),
            selectedCategories: selectedCategoriesRelay.asDriver(onErrorJustReturn: []),
            isNextEnabled: isNextEnabled.asDriver(onErrorJustReturn: false),
            navigateToPrev: navigateToPrevRelay.asDriver(onErrorDriveWith: .empty()),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty()),
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal(),
            showGeneratedConfirmModal: showGeneratedConfirmModalRelay.asSignal(),
            showGenerationFailed: showGenerationFailedRelay.asSignal()
        )
    }
}
extension TravelHowViewModel {
    // MARK: Output accessors
    var transportation: String? {
        selectedTransportRelay.value?.title(for: UIControl.State.normal)
    }

    var categories: [String]? {
        selectedCategoriesRelay.value.compactMap { $0.title(for: UIControl.State.normal) }
    }
}
