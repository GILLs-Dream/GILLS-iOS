//
//  TravelHowViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelHowViewController: TravelViewController {
    private let rootView = TravelHowView()
    private let viewModel = TravelHowViewModel()
    private let flowViewModel: TravelRequestFlowViewModel
    private let disposeBag = DisposeBag()
    var onPrev: (() -> Void)?
    var onComplete: (() -> Void)?
    
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
        bindFlowViewModel()
        bindViewModel()
    }
    
    private func bindFlowViewModel() {
        if let transportTitle = flowViewModel.transportation.value {
            if let matchedButton = rootView.transportOptionView.transportButtons.first(where: {
                $0.title(for: .normal) == transportTitle
            }) {
                viewModel.selectedTransportRelay.accept(matchedButton)
            }
        }
        
        if let selectedCategoryTitles = flowViewModel.categories.value {
            let matchedButtons = rootView.categoryOptionView.categoryButtons.filter {
                guard let title = $0.title(for: .normal) else { return false }
                return selectedCategoryTitles.contains(title)
            }
            viewModel.selectedCategoriesRelay.accept(matchedButtons)
        }
    }
    
    private func bindViewModel() {
        rootView.headerView.currentStep = 3
        
        let transportTapStream = Observable.merge(rootView.transportOptionView.transportButtons.map { button in
            button.rx.tap.map { button }
        })
        
        let categoryTapStream = Observable.merge(rootView.categoryOptionView.categoryButtons.map { button in
            button.rx.tap.map { button }
        })
        
        let input = TravelHowViewModel.Input(
            transportTapped: transportTapStream,
            categoryTapped: categoryTapStream,
            prevButtonTapped: rootView.previousButton.rx.tap.asObservable(),
            doneButtonTapped: rootView.doneButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedTransport
            .drive(onNext: { [weak self] selected in
                guard let self = self else { return }
                self.rootView.transportOptionView.transportButtons.forEach {
                    $0.isSelected = ($0 == selected)
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedCategories
            .drive(onNext: { [weak self] selected in
                guard let self = self else { return }
                self.rootView.categoryOptionView.categoryButtons.forEach {
                    $0.updateTheme(selected.contains($0) ? .color : .transparent)
                }
            })
            .disposed(by: disposeBag)
        
        output.navigateToPrev
            .drive(onNext: { [weak self] in
                self?.flowViewModel.transportation.accept(self?.viewModel.transportation)
                self?.flowViewModel.categories.accept(self?.viewModel.categories)
                self?.onPrev?()
            })
            .disposed(by: disposeBag)

        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.flowViewModel.transportation.accept(self.viewModel.transportation)
                self.flowViewModel.categories.accept(self.viewModel.categories)
                
                if self.flowViewModel.isHowValid {
                    self.rootView.lottieView.startAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                        self?.rootView.lottieView.stopAnimating()
                        self?.onComplete?()
                    }
                } else {
                    ToastManager.shared.show(message: "필수 정보를 입력하지 않았습니다.")
                }
            })
            .disposed(by: disposeBag)
    }
}

