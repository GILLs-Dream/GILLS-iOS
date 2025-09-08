//
//  TravelWhoViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelWhoViewController: TravelViewController {
    private let rootView: TravelWhoView
    private let viewModel: TravelWhoViewModel
    private let flowViewModel: TravelRequestFlowViewModel
    private let disposeBag = DisposeBag()
    var onPrev: (() -> Void)?
    var onNext: (() -> Void)?
    
    init(flowViewModel: TravelRequestFlowViewModel) {
        self.flowViewModel = flowViewModel
        self.rootView = TravelWhoView(titleText: flowViewModel.moodSummary)
        self.viewModel = TravelWhoViewModel(planId: flowViewModel.planId ?? -1)
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
        if let peopleCount = flowViewModel.peopleCount.value {
            rootView.travelPaxView.startField.textField.text = "\(peopleCount)"
        }
        
        if let peopleDetail = flowViewModel.peopleDetail.value {
            rootView.travelWhoView.startField.textField.text = peopleDetail
        }
    }

    private func bindViewModel() {
        rootView.headerView.currentStep = 1

        let peopleCountInput = rootView.travelPaxView.startField.textField.rx.text
            .orEmpty
            .compactMap { Int($0) }
            .distinctUntilChanged()
        
        let peopleDetailInput = rootView.travelWhoView.startField.textField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(rootView.travelWhoView.startField.textField.rx.text.orEmpty)

        let input = TravelWhoViewModel.Input(
            peopleCountInput: peopleCountInput,
            peopleDetailInput: peopleDetailInput,
            prevButtonTapped: rootView.previousButton.rx.tap.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.errorMessage
            .emit(onNext: { msg in ToastManager.shared.show(message: msg) })
            .disposed(by: disposeBag)

        output.navigateToPrev
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.flowViewModel.peopleCount.accept(self.viewModel.peopleCount)
                self.flowViewModel.peopleDetail.accept(self.viewModel.peopleDetail)
                self.onPrev?()
            })
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.flowViewModel.peopleCount.accept(self.viewModel.peopleCount)
                self.flowViewModel.peopleDetail.accept(self.viewModel.peopleDetail)
                self.onNext?()
            })
            .disposed(by: disposeBag)
    }
}
