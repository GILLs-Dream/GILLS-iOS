//
//  TravelWhereViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class TravelWhereViewController: TravelViewController {
    private let rootView = TravelWhereView()
    private let viewModel = TravelWhereViewModel()
    private let flowViewModel: TravelRequestFlowViewModel
    private let disposeBag = DisposeBag()
    
    private let placeAddedSubject = PublishSubject<Place>()
    private let deleteIndexPathSubject = PublishSubject<IndexPath>()
    private let calendarTappedSubject = PublishSubject<(IndexPath)>()
    private let currentPageRelay = BehaviorRelay<Int>(value: 0)
    var onPrev: (() -> Void)?
    var onNext: (() -> Void)?
    
    init(flowViewModel: TravelRequestFlowViewModel) {
        self.flowViewModel = flowViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindFlowViewModel()
        bindViewModel()
        bindTableViewHeight()
    }
    
    private func setupTableView() {
        rootView.placeTableView.register(TravelPlaceCell.self, forCellReuseIdentifier: TravelPlaceCell.identifier)
        rootView.stayTableView.register(TravelPlaceCell.self, forCellReuseIdentifier: TravelPlaceCell.identifier)
    }
    
    private func bindFlowViewModel() {
        let travel = flowViewModel.travelPlaces.value ?? []
        let stay = flowViewModel.stayPlaces.value ?? []
        viewModel.setInitialPlaces(travel: travel, stay: stay)
    }

    private func bindViewModel() {
        rootView.headerView.currentStep = 2

        let input = TravelWhereViewModel.Input(
            placeAdded: placeAddedSubject.asObservable(),
            calendarIndexPath: calendarTappedSubject.asObservable(),
            deleteIndexPath: deleteIndexPathSubject.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable(),
            prevButtonTapped: rootView.previousButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        // 여행지
        output.placeSections
            .drive(rootView.placeTableView.rx.items(dataSource: dataSource(forPage: 0)))
            .disposed(by: disposeBag)

        // 숙소
        output.staySections
            .drive(rootView.stayTableView.rx.items(dataSource: dataSource(forPage: 1)))
            .disposed(by: disposeBag)

        output.currentTitleText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateTitle(text: text)
            })
            .disposed(by: disposeBag)
        
        output.currentPage
            .drive(onNext: { [weak self] page in
                guard let self = self else { return }
                self.currentPageRelay.accept(page)
                self.rootView.placeTableView.isHidden = page != 0
                self.rootView.stayTableView.isHidden = page != 1
                self.rootView.updatePage(text: "\(page + 1)/2")

                self.rootView.addButtonTopConstraint?.deactivate()
                self.rootView.addButton.snp.makeConstraints {
                    self.rootView.addButtonTopConstraint = $0.top.equalTo(
                        page == 0 ? self.rootView.placeTableView.snp.bottom : self.rootView.stayTableView.snp.bottom
                    ).offset(16).constraint
                }
            })
            .disposed(by: disposeBag)

        output.isAddButtonHidden
            .drive(rootView.addButton.rx.isHidden)
            .disposed(by: disposeBag)

        output.showDatePicker
            .subscribe(onNext: { [weak self] indexPath, type in
                guard let self = self else { return }
                self.presentDatePicker(for: indexPath, type: type)
            })
            .disposed(by: disposeBag)

        rootView.addButton.rx.tap
            .withLatestFrom(currentPageRelay)
            .map { page in
                if (page == 0) {
                    return Place(id: "1", name: "길순이네 카페", imageURL: "UIImage.imgDefaultProfile", type: .travel)
                } else {
                    return Place(id: "1", name: "길순이네 민박", imageURL: "UIImage.imgDefaultProfile", type: .stay)
                }
            }
            .bind(to: placeAddedSubject)
            .disposed(by: disposeBag)
        
        output.navigatePrev
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.flowViewModel.travelPlaces.accept(self.viewModel.travelPlaces)
                self.flowViewModel.stayPlaces.accept(self.viewModel.stayPlaces)
                self.onPrev?()
            })
            .disposed(by: disposeBag)

        output.navigateNext
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.flowViewModel.travelPlaces.accept(self.viewModel.travelPlaces)
                self.flowViewModel.stayPlaces.accept(self.viewModel.stayPlaces)
                self.onNext?()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindTableViewHeight() {
        rootView.placeTableView.rx.observe(CGSize.self, "contentSize")
            .compactMap { $0?.height }
            .bind(onNext: { [weak self] height in
                guard let self = self else { return }
                self.rootView.placeTableView.snp.updateConstraints {
                    $0.height.equalTo(height)
                }
            })
            .disposed(by: disposeBag)
        
        rootView.stayTableView.rx.observe(CGSize.self, "contentSize")
            .compactMap { $0?.height }
            .bind(onNext: { [weak self] height in
                guard let self = self else { return }
                self.rootView.stayTableView.snp.updateConstraints {
                    $0.height.equalTo(height)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func dataSource(forPage page: Int) -> RxTableViewSectionedReloadDataSource<PlaceSection> {
        return RxTableViewSectionedReloadDataSource<PlaceSection>(
            configureCell: { [weak self] _, tableView, indexPath, item in
                guard let self,
                      let cell = tableView.dequeueReusableCell(withIdentifier: TravelPlaceCell.identifier, for: indexPath) as? TravelPlaceCell else {
                    return UITableViewCell()
                }
                cell.configure(with: item)
                cell.deleteTapped
                    .bind(onNext: { [weak self] in
                        self?.deleteIndexPathSubject.onNext(indexPath)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.calendarTapped
                    .bind(onNext: { [weak self] in
                        self?.calendarTappedSubject.onNext(indexPath)
                    })
                    .disposed(by: cell.disposeBag)

                return cell
            }
        )
    }
}

extension TravelWhereViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

extension TravelWhereViewController {
    private func presentDatePicker(for indexPath: IndexPath, type: DatePickerType) {
        switch type {
        case .single:
            let vc = DatePickerViewController()
            vc.onDateSelected = { date in
                self.viewModel.updateDate(for: indexPath, date: date)
            }
            presentBottomSheet(vc)

        case .range:
            let vc = DateRangePickerController()
            vc.onDateRangeSelected = { start, end in
                self.viewModel.updateDateRange(for: indexPath, checkInDate: start, checkOutDate: end)
            }
            presentBottomSheet(vc)
        }
    }

    private func presentBottomSheet(_ vc: UIViewController) {
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        self.present(vc, animated: true)
    }

}
