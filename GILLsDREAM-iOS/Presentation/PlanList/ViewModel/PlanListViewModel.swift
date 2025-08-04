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


let myPlanDummy = [
    Plan(id: "1", title: "깔루아 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: true, imageURL: nil, sortOrder: 0),
    Plan(id: "2", title: "길순이 경주여행", dateRange: nil, isPinned: true, imageURL: nil, sortOrder: 1),
    Plan(id: "3", title: "닐순이 경주여행", dateRange: nil, isPinned: true, imageURL: nil, sortOrder: 2),
    Plan(id: "4", title: "딜순이 경주여행", dateRange: nil, isPinned: true, imageURL: nil, sortOrder: 3),
    Plan(id: "5", title: "릴순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 4),
    Plan(id: "6", title: "밀순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 5),
    Plan(id: "7", title: "빌순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 6),
    Plan(id: "8", title: "실순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 7),
    Plan(id: "9", title: "일순이 경주여행", dateRange: "2025년 11월 24일 - 11월 25일", isPinned: false, imageURL: nil, sortOrder: 8),
]
