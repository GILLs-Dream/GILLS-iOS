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
    private let disposeBag = DisposeBag()
    
    private let placeAddedSubject = PublishSubject<Place>()
    private let deleteIndexPathSubject = PublishSubject<IndexPath>()
    private let calendarTappedSubject = PublishSubject<(IndexPath)>()
    private let currentPageRelay = BehaviorRelay<Int>(value: 0)
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
        bindTableViewHeight()
    }
    
    private func setupTableView() {
        rootView.placeTableView.register(TravelPlaceCell.self, forCellReuseIdentifier: TravelPlaceCell.identifier)
    }
    private func bindViewModel() {
        rootView.headerView.currentStep = 2

        let input = TravelWhereViewModel.Input(
            placeAdded: placeAddedSubject.asObservable(),
            calendarIndexPath: calendarTappedSubject.asObservable(),
            deleteIndexPath: deleteIndexPathSubject.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable(),
            prevButtonTapped: rootView.previousButton.rx.tap.asObservable(),
        )
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .drive(rootView.placeTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.isAddButtonHidden
            .drive(rootView.addButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.currentTitleText
            .drive(onNext: { [weak self] text in
                guard let self = self else { return }
                self.rootView.updateTitle(text: text)
            })
            .disposed(by: disposeBag)
        
        output.currentPage
            .drive(onNext: { [weak self] page in
                guard let self = self else { return }
                self.rootView.updatePage(text: "\(page+1)/2")
                self.rootView.updateButtons(for: page)
            })
            .disposed(by: disposeBag)
        
        output.showDatePicker
            .subscribe(onNext: { [weak self] indexPath, type in
                guard let self = self else { return }
                self.presentDatePicker(for: indexPath, type: type)
            })
            .disposed(by: disposeBag)
        
        // TODO: MapVC로 연결
        rootView.addButton.rx.tap
            .withLatestFrom(currentPageRelay)
            .map { page in
                let type: PlaceType = page == 0 ? .travel : .stay
                return Place(name: "길순이네 카페", imageURL: UIImage.imgDefaultProfile, type: type)
            }
            .bind(to: placeAddedSubject)
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
    }
    
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<PlaceSection> = {
        return RxTableViewSectionedReloadDataSource<PlaceSection>(
            configureCell: { [weak self] _, tableView, indexPath, item in
                guard let self,
                      let cell = tableView.dequeueReusableCell(withIdentifier: TravelPlaceCell.identifier, for: indexPath) as? TravelPlaceCell else {
                    return UITableViewCell()
                }
                cell.configure(with: item)
                cell.deleteTapped
                    .bind(onNext: { [weak self] in
                        guard let self = self else { return }
                        self.deleteIndexPathSubject.onNext(indexPath)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.calendarTapped
                    .bind(onNext: { [weak self] in
                        guard let self = self else { return }
                        self.calendarTappedSubject.onNext(indexPath)
                    })
                    .disposed(by: cell.disposeBag)
                return cell
            }
        )
    }()
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
