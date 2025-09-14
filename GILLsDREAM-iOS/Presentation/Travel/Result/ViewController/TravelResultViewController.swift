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
    
    typealias TimelineSection = SectionModel<Void, TravelTimelineRow>

    //MARK: Properties
    private let columns = 5
    private let itemHeight: CGFloat = 28
    private let interItem: CGFloat = 6
    private let lineSpacing: CGFloat = 10
    
    //MARK: States
    private var currentSelectedIndex = 0
    private var daysCount: Int = 0
    private let timelineItemsRelay = BehaviorRelay<[TimelineItem]>(value: [])

    private let disposeBag = DisposeBag()
    private let rootView = TravelResultView()
    private let viewModel: TravelResultViewModel

    var shouldHideSaveButton: Bool = false
    var onMap: (([TimelineItem]) -> Void)?
    var onSave: (() -> Void)?

    init(planId: Int) {
        self.viewModel = TravelResultViewModel(planId: planId)
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
        rootView.saveButton.isHidden = shouldHideSaveButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeight(itemsCount: daysCount + 1)
    }
    
    private func setUpCollectionViewDelegate() {
        rootView.travelDaysCollectionView.delegate = self
    }
    
    private func bindViewModel() {
        let input = TravelResultViewModel.Input(
            viewWillAppear: Observable.just(()),
            daySelected: rootView.travelDaysCollectionView.rx.itemSelected.map(\.item)
        )
        
        let output = viewModel.transform(input: input)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<DaySection>(
            configureCell: { [weak self] (_, collectionView, indexPath, index) in
                guard
                    let self = self,
                    let cell = collectionView.dequeueReusableCell(
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
        
        output.sections
            .drive(rootView.travelDaysCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                guard let self else { return }
                let hostView = self.tabBarController?.view ?? self.view.window ?? self.view
                if isLoading {
                    LoadingOverlayView.shared.updateText("길동이가\n여행 결과를 불러오고 있어요!")
                    LoadingOverlayView.shared.show(in: hostView!)
                } else {
                    LoadingOverlayView.shared.hide()
                }
            })
            .disposed(by: disposeBag)
        
        let tableDataSource = RxTableViewSectionedReloadDataSource<TimelineSection>(
            configureCell: { [weak self] (_, tableView, indexPath, row) in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: TravelTimelineCell.identifier,
                    for: indexPath
                ) as? TravelTimelineCell else { return UITableViewCell() }

                switch row {
                case .start(let place):
                    cell.configureStart(place: place) // 첫 셀
                case .route(let route):
                    cell.configureRoute(route) // 이후 셀
                }
                return cell
            }
        )
        
        output.selectedIndex
            .drive(onNext: { [weak self] idx in
                guard let self else { return }
                self.currentSelectedIndex = idx
                self.rootView.travelDaysCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.timeline
            .map { [TimelineSection(model: (), items: $0)] }
            .drive(rootView.travelDayResultView.travelTimelineTableView.rx.items(dataSource: tableDataSource))
            .disposed(by: disposeBag)

        output.title
            .drive(onNext: { [weak self] t in
                guard let self, let result = self.viewModel.resultRelay.value else { return }
                self.rootView.configure(plan: result)
            })
            .disposed(by: disposeBag)

        // 요약 연결 (뷰 제공 메서드 사용)
        output.summary
            .drive(onNext: { [weak self] s in
                guard let self, let summary = s else { return }
                self.rootView.configure(summary: summary)
            })
            .disposed(by: disposeBag)
        
        output.isSummaryMode
            .drive(onNext: { [weak self] isSummary in
                guard let self else { return }
                self.rootView.summaryView.isHidden = !isSummary
                self.rootView.travelDayResultView.isHidden = isSummary
            })
            .disposed(by: disposeBag)

        // Days 타이틀 표시도 duration 기준으로
        output.daysCount
            .drive(onNext: { [weak self] count in
                guard let self else { return }
                self.daysCount = count
                self.rootView.travelDaysCollectionView.reloadData()
                self.updateCollectionHeight(itemsCount: count + 1)
            })
            .disposed(by: disposeBag)
        
        rootView.saveButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.onSave?()
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

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItem
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}
