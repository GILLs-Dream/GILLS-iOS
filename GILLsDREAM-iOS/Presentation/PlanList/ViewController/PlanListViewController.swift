//
//  PlanListViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class PlanListViewController: BaseViewController {
    private let rootView = PlanListView()
    private let viewModel = PlanListViewModel()
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        makeRefreshControl()
    }
    
    private func makeRefreshControl() {
        refreshControl.tintColor = .white
        rootView.myPlanCollectionView.refreshControl = refreshControl
        rootView.myPlanCollectionView.alwaysBounceVertical = true
    }

    private func bindViewModel() {
        // 최초 1회 로드
        let firstAppear = rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
            .map { _ in () }
            .take(1)

        // 당겨서 새로고침 트리거
        let pullToRefresh = refreshControl.rx.controlEvent(.valueChanged)
            .map { () }

        // 최초 1회 + 당겨서 새로고침 둘 다 fetch 트리거로 사용
        let input = PlanListViewModel.Input(
            viewDidLoad: Observable.merge(firstAppear, pullToRefresh),
            itemSelected: rootView.myPlanCollectionView.rx.modelSelected(Plan.self).asObservable()
        )

        let output = viewModel.transform(input: input)

        output.planSections
            .drive(rootView.myPlanCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.planSections
            .drive(onNext: { [weak self] sections in
                guard let self else { return }
                let plans = sections.flatMap { $0.items }
                self.rootView.noPlanLabel.isHidden = !plans.isEmpty
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .emit(onNext: { message in
                ToastManager.shared.show(message: message)
            })
            .disposed(by: disposeBag)
        
        output.selectedPlan
            .emit(onNext: { [weak self] plan in
                // TODO: 상세 페이지 이동
                // self?.navigateToDetail(plan: plan)
            })
            .disposed(by: disposeBag)
    }

    // MARK: DataSource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<PlanSection>(
        configureCell: { [weak self] _, collectionView, indexPath, item in
            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PlanListCollectionViewCell.identifier,
                    for: indexPath
                  ) as? PlanListCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: item)

            cell.onPin = { [weak self] in
                self?.viewModel.togglePin(for: item)
            }

            cell.onUnpin = { [weak self] in
                self?.viewModel.togglePin(for: item)
            }

            cell.onConvertToPDF = {
                // TODO: PDF 변환 로직
            }

            cell.onShare = {
                // TODO: 공유 기능
            }
            return cell
        }
    )
}
