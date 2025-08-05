//
//  TravelWhereViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum DatePickerType {
    case single
    case range
}

final class TravelWhereViewModel {
    struct Input {
        let placeAdded: Observable<Place>
        let calendarIndexPath: Observable<IndexPath>
        let deleteIndexPath: Observable<IndexPath>
        let nextButtonTapped: Observable<Void>
        let prevButtonTapped: Observable<Void>
    }

    struct Output {
        let placeSections: Driver<[PlaceSection]>
        let staySections: Driver<[PlaceSection]>
        let isAddButtonHidden: Driver<Bool>
        let currentPage: Driver<Int>
        let currentTitleText: Driver<String>
        let navigatePrev: Signal<Void>
        let navigateNext: Signal<Void>
        let showDatePicker: Observable<(IndexPath, DatePickerType)>
    }

    private let disposeBag = DisposeBag()
    private let navigateToPrevRelay = PublishRelay<Void>()
    private let navigateToNextRelay = PublishRelay<Void>()
    private let pageRelay = BehaviorRelay<Int>(value: 0)
    private let travelPlacesRelay = BehaviorRelay<[Place]>(value: [])
    private let stayPlacesRelay = BehaviorRelay<[Place]>(value: [])
    private let showDatePickerRelay = PublishRelay<(IndexPath, DatePickerType)>()

    func transform(input: Input) -> Output {
        // 여행지 or 숙소 추가
        input.placeAdded
            .withLatestFrom(pageRelay) { ($0, $1) }
            .subscribe(onNext: { [weak self] place, page in
                guard let self = self else { return }
                let current = self.getCurrentPlaces(for: page)
                current.accept(current.value + [place])
            }).disposed(by: disposeBag)

        // 날짜 선택
        input.calendarIndexPath
            .withLatestFrom(pageRelay) { ($0, $1) }
            .map { indexPath, page -> (IndexPath, DatePickerType) in
                let type: DatePickerType = page == 0 ? .single : .range
                return (indexPath, type)
            }
            .bind(to: showDatePickerRelay)
            .disposed(by: disposeBag)

        // 삭제
        input.deleteIndexPath
            .withLatestFrom(pageRelay) { ($0, $1) }
            .subscribe(onNext: { [weak self] indexPath, page in
                guard let self = self else { return }
                let current = self.getCurrentPlaces(for: page)
                var items = current.value
                items.remove(at: indexPath.row)
                current.accept(items)
            }).disposed(by: disposeBag)

        // 페이지 이동
        input.prevButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.pageRelay.value == 1 {
                    self.pageRelay.accept(0)
                } else {
                    self.navigateToPrevRelay.accept(())
                }
            }).disposed(by: disposeBag)

        input.nextButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.pageRelay.value == 0 {
                    self.pageRelay.accept(1)
                } else {
                    self.navigateToNextRelay.accept(())
                }
            }).disposed(by: disposeBag)

        // Output 생성
        let placeSections = travelPlacesRelay
            .map { [PlaceSection(items: $0)] }
            .asDriver(onErrorJustReturn: [])

        let staySections = stayPlacesRelay
            .map { [PlaceSection(items: $0)] }
            .asDriver(onErrorJustReturn: [])

        let isAddButtonHidden = Observable
            .combineLatest(pageRelay, travelPlacesRelay, stayPlacesRelay)
            .map { page, travel, stay in
                let count = (page == 0) ? travel.count : stay.count
                return count >= 5
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let titleText = pageRelay
            .map { $0 == 0 ? "STEP 3. 생각해둔 여행지가 있다면 추가해주세요. (선택)" : "STEP 3. 예약해둔 숙소가 있다면 추가해주세요. (선택)" }
            .asDriver(onErrorJustReturn: "")

        return Output(
            placeSections: placeSections,
            staySections: staySections,
            isAddButtonHidden: isAddButtonHidden,
            currentPage: pageRelay.asDriver(),
            currentTitleText: titleText,
            navigatePrev: navigateToPrevRelay.asSignal(),
            navigateNext: navigateToNextRelay.asSignal(),
            showDatePicker: showDatePickerRelay.asObservable()
        )
    }

    private func getCurrentPlaces(for page: Int) -> BehaviorRelay<[Place]> {
        return page == 0 ? travelPlacesRelay : stayPlacesRelay
    }
}

extension TravelWhereViewModel {
    func updateDate(for indexPath: IndexPath, date: Date) {
        let current = getCurrentPlaces(for: pageRelay.value)
        var items = current.value
        guard indexPath.row < items.count else { return }
        var updatedPlace = items[indexPath.row]
        updatedPlace.type = .travel
        updatedPlace.visitDate = date
        items[indexPath.row] = updatedPlace
        current.accept(items)
    }

    func updateDateRange(for indexPath: IndexPath, checkInDate: Date, checkOutDate: Date) {
        let current = getCurrentPlaces(for: pageRelay.value)
        var items = current.value
        guard indexPath.row < items.count else { return }
        var updatedPlace = items[indexPath.row]
        updatedPlace.type = .stay
        updatedPlace.checkInDate = checkInDate
        updatedPlace.checkOutDate = checkOutDate
        items[indexPath.row] = updatedPlace
        current.accept(items)
    }
    
    func setInitialPlaces(travel: [Place], stay: [Place]) {
        travelPlacesRelay.accept(travel)
        stayPlacesRelay.accept(stay)
    }
    
    // MARK: Output accessors
    var currentPageValue: Int {
        return pageRelay.value
    }
    
    var travelPlaces: [Place]? {
        return travelPlacesRelay.value
    }

    var stayPlaces: [Place]? {
        return stayPlacesRelay.value
    }
}
