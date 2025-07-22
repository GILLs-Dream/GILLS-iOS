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
//        rootView.placeTableView.rx.setDelegate(self)
//            .disposed(by: disposeBag)
        rootView.placeTableView.register(TravelPlaceCell.self, forCellReuseIdentifier: TravelPlaceCell.identifier)
    }
    private func bindViewModel() {
        let input = TravelWhereViewModel.Input(
            placeAdded: placeAddedSubject.asObservable(),
            deleteIndexPath: deleteIndexPathSubject.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable(),
            prevButtonTapped: rootView.previousButton.rx.tap.asObservable()
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
                self.rootView.updateButtons(for: page)
            })
            .disposed(by: disposeBag)

        // TODO: MapVC로 연결
        rootView.addButton.rx.tap
            .map { Place(name: "길순이네 카페 \(Int.random(in: 1...100))", imageURL: UIImage.imgDefaultProfile) }
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
                return cell
            }
        )
    }()
}

extension TravelWhereViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
}
