//
//  TravelResultViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/6/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class TravelResultViewController: TravelViewController {
    
    //MARK: Properties
    private let columns = 5
    private let itemHeight: CGFloat = 28
    private let interItem: CGFloat = 6
    private let lineSpacing: CGFloat = 10
    
    //MARK: States
    private var currentSelectedIndex = 0
    private let daysCount: Int
    private let transportation: String
    private let timelineItemsRelay = BehaviorRelay<[DayPlaceItem]>(value: []) // 테이블 표시용
    
    private let disposeBag = DisposeBag()
    private let rootView = TravelResultView()
    private let viewModel = TravelResultViewModel()
    private let flowViewModel: TravelRequestFlowViewModel
    
    var onMap: (([DayPlaceItem]) -> Void)?
    var onSave: (() -> Void)?
    
    init(flowViewModel: TravelRequestFlowViewModel) {
        self.flowViewModel = flowViewModel
        self.daysCount = flowViewModel.travelDays.value ?? 1
        self.transportation = flowViewModel.transportation.value ?? "도보"
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
        setUpCollectionViewDelegate()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeight(itemsCount: daysCount + 1)
    }
    
    private func setUpCollectionViewDelegate() {
        rootView.travelDaysCollectionView.delegate = self
    }
    
    private func bindViewModel() {
        let items = Array(0...daysCount)
        let itemsStream = Observable.just(items)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<DaySection>(
            configureCell: { [weak self] _, cv, indexPath, index in
                guard
                    let self = self,
                    let cell = cv.dequeueReusableCell(
                        withReuseIdentifier: TravelDaysCollectionViewCell.identifier,
                        for: indexPath
                    ) as? TravelDaysCollectionViewCell
                else { return UICollectionViewCell() }
                
                let title = (index == self.daysCount) ? "요약" : "\(index + 1)일차"
                let isSelected = (indexPath.item == self.currentSelectedIndex)
                cell.configure(title: title, isSelected: isSelected)
                return cell
            }
        )
        
        let input = TravelResultViewModel.Input(
            items: itemsStream,
            didSelectIndex: rootView.travelDaysCollectionView.rx.itemSelected.map(\.item)
        )
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .drive(rootView.travelDaysCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.selectedIndex
            .drive(onNext: { [weak self] index in
                self?.currentSelectedIndex = index
                self?.rootView.travelDaysCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        let tableDataSource = RxTableViewSectionedReloadDataSource<TimelineSection>(
            configureCell: { [weak self] _, tableView, indexPath, item in
                guard
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: TravelTimelineCell.identifier,
                        for: indexPath
                    ) as? TravelTimelineCell
                else { return UITableViewCell() }

                let items = self?.timelineItemsRelay.value ?? []
                let isLast  = (indexPath.row == max(0, items.count - 1))
                cell.configure(item: item, isLast: isLast)
                return cell
            }
        )

        timelineItemsRelay
            .map { [TimelineSection(model: (), items: $0)] }
            .bind(to: rootView.travelDayResultView.travelTimelineTableView.rx.items(dataSource: tableDataSource))
            .disposed(by: disposeBag)

        output.selectedIndex
            .drive(onNext: { [weak self] index in
                guard let self = self else { return }
                self.currentSelectedIndex = index
                self.rootView.travelDaysCollectionView.reloadData()

                let isSummary = (index == self.daysCount)
                self.rootView.setContentMode(isSummary ? .summary : .day)

                if isSummary {
                    self.timelineItemsRelay.accept([])
                } else {
                    // TODO: API 연결
                    let safeIndex = max(0, min(index, mockTravelData.count - 1))
                    self.timelineItemsRelay.accept(mockTravelData[safeIndex])
                }
            })
            .disposed(by: disposeBag)

        timelineItemsRelay.accept(mockTravelData.first ?? [])
        
        rootView.travelDayResultView.transportationDetailLabel.attributedText = "*해당 계획은 \(self.transportation) 기준으로 생성되었습니다.".pretendardAttributedString(style: .body3)
        
        rootView.primaryButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                let isSummary = (self.currentSelectedIndex == self.daysCount)
                if isSummary { self.onSave?() }
                else { self.onMap?(self.timelineItemsRelay.value) }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateCollectionHeight(itemsCount: Int) {
        let rows = (itemsCount > columns) ? 2 : 1
        let height = CGFloat(rows) * itemHeight + CGFloat(rows - 1) * lineSpacing
        rootView.updateDaysHeight(height)
    }
}

extension TravelResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = interItem * CGFloat(columns - 1)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / CGFloat(columns))
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ cv: UICollectionView,
                        layout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItem
    }

    func collectionView(_ cv: UICollectionView,
                        layout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}
