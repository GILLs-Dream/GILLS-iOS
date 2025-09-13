//
//  TravelResultViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/6/25.
//

import RxSwift
import RxCocoa
import RxDataSources
import math_h

public typealias DaySection = SectionModel<Void, Int>

final class TravelResultViewModel {
    private let planId: Int
    private let usecase: PlanUsecase

    init(planId: Int, usecase: PlanUsecase = PlanUsecaseImpl(repository: PlanRepositoryImpl())) {
        self.planId = planId
        self.usecase = usecase
    }

    struct Input {
        let viewWillAppear: Observable<Void>
        let daySelected: Observable<Int>
    }

    struct Output {
        let sections: Driver<[DaySection]>
        let selectedIndex: Driver<Int>
        let timeline: Driver<[TravelTimelineRow]>
        let summary: Driver<PlanSummary?>
        let isSummaryMode: Driver<Bool>
        let title: Driver<String>
        let daysCount: Driver<Int>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }

    private let disposeBag = DisposeBag()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    let resultRelay = BehaviorRelay<PlanResult?>(value: nil)
    let summaryRelay = BehaviorRelay<PlanSummary?>(value: nil)
    private let selectedIndexRelay = BehaviorRelay<Int>(value: 0)
    private let timelineRelay = BehaviorRelay<[TravelTimelineRow]>(value: [])

    func transform(input: Input) -> Output {
        // 1) 최초 결과 로드
        input.viewWillAppear
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run { [weak self] in
                    guard let self else { return }
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                    let result = try await self.usecase.getGeneratedPlan(planId: self.planId)
                    await MainActor.run {
                        self.resultRelay.accept(result)
                        self.summaryRelay.accept(nil)
                        self.selectedIndexRelay.accept(0)
                        self.updateRows(with: result, dayIndex: 0)
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

        // 2) 날짜 선택
        input.daySelected
            .bind(to: selectedIndexRelay)
            .disposed(by: disposeBag)

        // 3) 선택 변경 → 타임라인/요약 로드
        Observable.combineLatest(selectedIndexRelay, resultRelay.compactMap { $0 })
            .flatMapLatest { [weak self] (index, result) -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run { [weak self] in
                    guard let self else { return }
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                    let lastIndex = result.duration
                    if index == lastIndex {
                        if let cached = self.summaryRelay.value {
                            await MainActor.run {
                                self.summaryRelay.accept(cached)
                                self.timelineRelay.accept([]) // 표는 비움
                            }
                        } else {
                            let summary = try await self.usecase.getGeneratedPlanSummary(planId: self.planId)
                            await MainActor.run {
                                self.summaryRelay.accept(summary)
                                self.timelineRelay.accept([])
                            }
                        }
                    } else {
                        await MainActor.run {
                            self.summaryRelay.accept(nil)
                            self.updateRows(with: result, dayIndex: index)
                        }
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

        // Sections: 마지막 = 요약
        let sections = resultRelay
            .map { result -> [DaySection] in
                let duration = result?.duration ?? 0
                let items = Array(0...max(0, duration))
                return [DaySection(model: (), items: items)]
            }
            .asDriver(onErrorJustReturn: [])

        let daysCount = resultRelay
            .map { $0?.duration ?? 0 }
            .asDriver(onErrorJustReturn: 0)

        let title = resultRelay
            .map { $0?.title ?? "" }
            .asDriver(onErrorJustReturn: "")

        let isSummaryMode = Observable
            .combineLatest(selectedIndexRelay, resultRelay.map { $0?.duration ?? 0 })
            .map { $0 == $1 }
            .asDriver(onErrorJustReturn: false)

        return Output(
            sections: sections,
            selectedIndex: selectedIndexRelay.asDriver(),
            timeline: timelineRelay.asDriver(),
            summary: summaryRelay.asDriver(),
            isSummaryMode: isSummaryMode,
            title: title,
            daysCount: daysCount,
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal()
        )
    }

    // MARK: Helpers
    private func updateRows(with result: PlanResult, dayIndex: Int) {
        let perDay = result.perDayList.first { $0.dayNum == dayIndex + 1 }
            ?? (dayIndex < result.perDayList.count ? result.perDayList[dayIndex] : nil)

        guard let day = perDay else {
            timelineRelay.accept([])
            return
        }

        var rows: [TravelTimelineRow] = [.start(day.from)]
        rows.append(contentsOf: day.routes.map { .route($0) })
        timelineRelay.accept(rows)
    }
}
