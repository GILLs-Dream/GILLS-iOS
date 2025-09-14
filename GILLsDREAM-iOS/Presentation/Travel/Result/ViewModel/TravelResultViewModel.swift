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
    private var rowsCache: [Int: [TravelTimelineRow]] = [:]
    private var summaryLoaded = false

    func transform(input: Input) -> Output {
        // 1) 최초 결과 로드
        input.viewWillAppear
            .take(1)
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return RxAsync.run { [weak self] in
                    guard let self else { return }
                    await MainActor.run { self.isLoadingRelay.accept(true) }

                    let result = try await self.usecase.getGeneratedPlan(planId: self.planId)
                    let summary = try await self.usecase.getGeneratedPlanSummary(planId: self.planId)
                    let builtCache = self.makeRowsCache(from: result)

                    await MainActor.run {
                        self.rowsCache = builtCache
                        self.resultRelay.accept(result)
                        self.selectedIndexRelay.accept(0)
                        self.timelineRelay.accept(builtCache[0] ?? [])
                        self.isLoadingRelay.accept(false)
                        self.summaryRelay.accept(summary)
                        self.summaryLoaded = true
                    }
                }
                .asObservable()
                .catch { [weak self] error in
                    Task { @MainActor in self?.isLoadingRelay.accept(false) }
                    self?.errorRelay.accept(error.displayMessage)
                    return .empty()
                }
            }
            .subscribe()
            .disposed(by: disposeBag)

        // 2) 날짜 선택
        input.daySelected
            .distinctUntilChanged()
            .bind(to: selectedIndexRelay)
            .disposed(by: disposeBag)

        // 3) 선택 변경 → 타임라인/요약 로드
        Observable.combineLatest(selectedIndexRelay, resultRelay.compactMap { $0 })
            .flatMapLatest { [weak self] (index, result) -> Observable<Void> in
                guard let self else { return .empty() }

                if index == result.duration {
                    if self.summaryRelay.value != nil {
                        self.timelineRelay.accept([]) // 표 숨김
                        return .just(())
                    } else {
                        // 처음 요약 요청 -> 그때만 로딩 켬
                        return RxAsync.run { [weak self] in
                            guard let self else { return }
                            await MainActor.run { self.isLoadingRelay.accept(true) }
                            defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                            let summary = try await self.usecase.getGeneratedPlanSummary(planId: self.planId)
                            await MainActor.run {
                                self.summaryRelay.accept(summary)
                                self.timelineRelay.accept([]) // 표 숨김
                            }
                        }
                        .asObservable()
                        .catch { [weak self] error in
                            self?.errorRelay.accept(error.displayMessage)
                            return .empty()
                        }
                    }
                } else {
                    // n일차: 캐시 즉시 바인딩
                    let rows = self.rowsCache[index] ?? []
                    self.summaryRelay.accept(nil)
                    self.timelineRelay.accept(rows)
                    return .just(())
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
    private func makeRowsCache(from result: PlanResult) -> [Int: [TravelTimelineRow]] {
        var cache: [Int: [TravelTimelineRow]] = [:]
        let days = result.perDayList
        for idx in 0 ..< result.duration {
            if let day = days.first(where: { $0.dayNum == idx + 1 }) ?? days[safe: idx] {
                var rows: [TravelTimelineRow] = [.start(day.from)]
                rows.append(contentsOf: day.routes.map { .route($0) })
                cache[idx] = rows
            } else {
                cache[idx] = []
            }
        }
        return cache
    }
    
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

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
