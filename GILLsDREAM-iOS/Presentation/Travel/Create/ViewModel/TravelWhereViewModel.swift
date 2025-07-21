//
//  TravelWhereViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelWhereViewModel {

    struct Input {
        let placeAdded: Observable<Place>
        let placeDeleted: Observable<Place>
        let nextButtonTapped: Observable<Void>
        let prevButtonTapped: Observable<Void>
    }

    struct Output {
        let placeList: Driver<[Place]>
        let isAddButtonHidden: Driver<Bool>
        let currentPage: Driver<Int>
        let currentTitleText: Driver<String>
        let navigateToNext: Driver<Void>
    }

    private let disposeBag = DisposeBag()

    private let navigateToNextRelay = PublishRelay<Void>()
    private let placeListRelay = BehaviorRelay<[Place]>(value: [])
    private let currentPageRelay = BehaviorRelay<Int>(value: 0)

    func transform(input: Input) -> Output {
        input.placeAdded
            .withLatestFrom(placeListRelay) { ($0, $1) }
            .filter { $1.count < 5 }
            .map { newPlace, list in list + [newPlace] }
            .bind(to: placeListRelay)
            .disposed(by: disposeBag)

        input.placeDeleted
            .withLatestFrom(placeListRelay) { ($0, $1) }
            .map { deleted, list in list.filter { $0 != deleted } }
            .bind(to: placeListRelay)
            .disposed(by: disposeBag)

        input.nextButtonTapped
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                let nextPage = self.currentPageRelay.value + 1
                if nextPage <= 1 {
                    self.currentPageRelay.accept(nextPage)
                    self.placeListRelay.accept([]) // 페이지 바뀌면 리스트 초기화
                } else {
                    self.navigateToNextRelay.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.prevButtonTapped
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                let current = self.currentPageRelay.value
                if current > 0 {
                    self.currentPageRelay.accept(current - 1)
                    self.placeListRelay.accept([]) // 페이지 변경 시 초기화
                }
            })
            .disposed(by: disposeBag)

        let isAddButtonHidden = placeListRelay
            .map { $0.count >= 5 }

        let currentTitleText = currentPageRelay
            .map { page in
                switch page {
                case 0: return "STEP 3. 생각해둔 여행지가 있나요?"
                case 1: return "STEP 3. 미리 예약해둔 숙소가 있으면 추가해주세요."
                default: return ""
                }
            }

        return Output(
            placeList: placeListRelay.asDriver(),
            isAddButtonHidden: isAddButtonHidden.asDriver(onErrorJustReturn: false),
            currentPage: currentPageRelay.asDriver(),
            currentTitleText: currentTitleText.asDriver(onErrorJustReturn: ""),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    func addPlace(_ place: Place) {
        var current = placeListRelay.value
        guard current.count < 5 else { return }
        current.append(place)
        placeListRelay.accept(current)
    }

    var places: Observable<[Place]> {
        return placeListRelay.asObservable()
    }
    
}

struct Place: Equatable {
    let id = UUID()
    let name: String
    let imageURL: UIImage

    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
}
