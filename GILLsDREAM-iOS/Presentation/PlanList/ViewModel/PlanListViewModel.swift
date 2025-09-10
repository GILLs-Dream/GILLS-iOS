//
//  PlanListViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

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
    }
    
    struct Output {
        let planSections: Driver<[PlanSection]>
        let selectedPlan: Signal<Plan>
        let errorMessage: Signal<String>
    }
    
    private let planSectionsRelay = BehaviorRelay<[PlanSection]>(value: [])
    private let errorRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .flatMapLatest { _ in
                RxAsync.run { [weak self] () async throws -> [Plan] in
                    guard let self else { return [] }
                    return try await self.usecase.fetchMyPlans()
                }
                .asObservable()
                .catch { [weak self] error in
                    guard let self = self else { return .empty() }
                    self.errorRelay.accept("서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.")
                    return .empty()
                }
            }
            .map { [PlanSection(items: $0)] }
            .bind(to: planSectionsRelay)
            .disposed(by: disposeBag)
        
        return Output(
            planSections: planSectionsRelay.asDriver(),
            selectedPlan: input.itemSelected.asSignal(onErrorSignalWith: .empty()),
            errorMessage: errorRelay.asSignal()
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
