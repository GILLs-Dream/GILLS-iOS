//
//  TravelWhereViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelWhereViewController: TravelViewController {
    private let rootView = TravelWhereView()
    private let viewModel = TravelWhereViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupActions()
    }
    
    private func bindViewModel() {
        rootView.headerView.currentStep = 2
        
        let input = TravelWhereViewModel.Input(
            placeAdded: placeAddedSubject.asObservable(),
            placeDeleted: placeDeletedSubject.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable(),
            prevButtonTapped: rootView.previousButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.placeList
            .drive(onNext: { [weak self] places in
                self?.updatePlaceCells(with: places)
            })
            .disposed(by: disposeBag)
        
        output.isAddButtonHidden
            .drive(rootView.addButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.currentTitleText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateTitle(text: text)
            })
            .disposed(by: disposeBag)
        
        output.currentPage
            .drive(onNext: { [weak self] page in
                guard let self = self else { return }
                self.rootView.pageLabel.text = "\(page + 1)/2"
                self.rootView.updateButtons(for: page)
            })
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .drive(onNext: { [weak self] in
                let nextVC = TravelWhereViewController() // 예시
                nextVC.view.backgroundColor = .white
                self?.navigationController?.pushViewController(nextVC, animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    private let placeAddedSubject = PublishSubject<Place>()
    private let placeDeletedSubject = PublishSubject<Place>()
    
    private func setupActions() {
        rootView.addButton.addTarget(self, action: #selector(addPlace), for: .touchUpInside)
    }
    
    private func updatePlaceCells(with places: [Place]) {
        rootView.updatePlaceStack(with: places) { [weak self] place in
            self?.placeDeletedSubject.onNext(place)
        }
    }
    
    @objc private func addPlace() {
        let dummyPlace1 = Place(name: "장소1", imageURL: UIImage.imgDefaultProfile)
        viewModel.addPlace(dummyPlace1)
    }
}
