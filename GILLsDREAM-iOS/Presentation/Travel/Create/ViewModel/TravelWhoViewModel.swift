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
    }
    
    private let disposeBag = DisposeBag()
    
    private let peopleCountRelay = BehaviorRelay<Int?>(value: nil)
    private let peopleDetailRelay = BehaviorRelay<String?>(value: nil)
    private let isNextEnabledRelay = BehaviorRelay<Bool>(value: false)
    private let navigateToPrevRelay = PublishRelay<Void>()
    private let navigateToNextRelay = PublishRelay<Void>()
    
    func transform(input: Input) -> Output {
        
        input.peopleCountInput
            .do(onNext: { [weak self] pax in
                self?.peopleCountRelay.accept(pax)
            })
            .map { _ in true }
            .bind(to: isNextEnabledRelay)
            .disposed(by: disposeBag)
        
        input.peopleDetailInput
            .subscribe(onNext: { [weak self] detail in
                self?.peopleDetailRelay.accept(detail)
            })
            .disposed(by: disposeBag)
        
        input.prevButtonTapped
            .bind(to: navigateToPrevRelay)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .bind(to: navigateToNextRelay)
            .disposed(by: disposeBag)
        
        return Output(
            isNextEnabled: isNextEnabledRelay.asDriver(onErrorJustReturn: false),
            navigateToPrev: navigateToPrevRelay.asDriver(onErrorDriveWith: .empty()),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty())
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
