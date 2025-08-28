//
//  PlanListViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import RxSwift
import RxCocoa

final class PlanListViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let itemSelected: Observable<Plan>
    }
    
    struct Output {
        let planSections: Driver<[PlanSection]>
        let selectedPlan: Signal<Plan>
    }
    
    private let planSectionsRelay = BehaviorRelay<[PlanSection]>(value: [])
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .map { _ in
                return [PlanSection(items: myPlanDummy)]
            }
            .bind(to: planSectionsRelay)
            .disposed(by: disposeBag)
        
        return Output(
            planSections: planSectionsRelay.asDriver(),
            selectedPlan: input.itemSelected.asSignal(onErrorSignalWith: .empty()),
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
