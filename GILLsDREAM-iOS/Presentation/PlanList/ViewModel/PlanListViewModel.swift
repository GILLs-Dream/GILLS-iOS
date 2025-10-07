//
//  PlanListViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import Foundation
import RxSwift
import RxCocoa

final class PlanListViewModel {
    private let usecase: PlanUsecase
    
    init(usecase: PlanUsecase = PlanUsecaseImpl(repository: PlanRepositoryImpl())) {
        self.usecase = usecase
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let itemSelected: Observable<Plan>
        let pdfRequested: Observable<Plan>
    }
    
    struct Output {
        let planSections: Driver<[PlanSection]>
        let selectedPlan: Signal<Plan>
        let exportedPDFURL: Signal<URL>
        let errorMessage: Signal<String>
        let isLoading: Driver<Bool>
    }
    
    private let planSectionsRelay = BehaviorRelay<[PlanSection]>(value: [])
    private let exportedPDFRelay = PublishRelay<URL>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .flatMapLatest { [weak self] _ in
                guard let self else { return Observable<[Plan]>.just([]) }
                return RxAsync.run {
                    await MainActor.run { self.isLoadingRelay.accept(true) } // 로딩 on
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } } // 로딩 off
                    return try await self.usecase.fetchMyPlans()
                }
                .asObservable()
                .catch { [weak self] error in
                    self?.errorRelay.accept("서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.")
                    return .just([])
                }
            }
            .map { [PlanSection(items: $0)] }
            .bind(to: planSectionsRelay)
            .disposed(by: disposeBag)
        
        input.pdfRequested
            .flatMapLatest { [weak self] plan -> Observable<URL> in
                guard let self else { return .empty() }
                return RxAsync.run {
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }
                    return try await self.usecase.exportPlanPDF(planId: plan.id, title: plan.title)
                }
                .asObservable()
                .catch { [weak self] _ in
                    self?.errorRelay.accept("PDF 내보내기에 실패했어요. 잠시 후 다시 시도해 주세요.")
                    return .empty()
                }
            }
            .filter {
                FileManager.default.fileExists(atPath: $0.path)
            }
            .bind(to: exportedPDFRelay)
            .disposed(by: disposeBag)
        
        return Output(
            planSections: planSectionsRelay.asDriver(),
            selectedPlan: input.itemSelected.asSignal(onErrorSignalWith: .empty()),
            exportedPDFURL: exportedPDFRelay.asSignal(),
            errorMessage: errorRelay.asSignal(),
            isLoading: isLoadingRelay.asDriver()
        )
    }
}

extension PlanListViewModel {
    // MARK: Toggle Pinned
    func togglePin(for plan: Plan) {
        var current = planSectionsRelay.value.flatMap { $0.items }
        
        guard let index = current.firstIndex(where: { $0.id == plan.id }) else { return }
        let updatedPlan = plan.toggledPinned()
        current[index] = updatedPlan
        
        // 정렬 기준: 고정 -> sortOrder 순
        let sorted = current.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            } else {
                return $0.sortOrder < $1.sortOrder
            }
        }
        planSectionsRelay.accept([PlanSection(items: sorted)])
    }
}
