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

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        let input = PlanListViewModel.Input(
            viewDidLoad: Observable.just(()),
            itemSelected: rootView.myPlanCollectionView.rx.modelSelected(Plan.self).asObservable(),
        )

        let output = viewModel.transform(input: input)

        output.planSections
            .drive(rootView.myPlanCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.selectedPlan
            .emit(onNext: { plan in
                // TODO: 상세 페이지 이동
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
