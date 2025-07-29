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
    private let rootView = TravelWhoView()
    private let viewModel = TravelWhoViewModel()
    private let disposeBag = DisposeBag()
    var onPrev: (() -> Void)?
    var onNext: (() -> Void)?
    
    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        rootView.headerView.currentStep = 1

        let paxInput = rootView.travelPaxView.startField.textField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(rootView.travelPaxView.startField.textField.rx.text.orEmpty)
            .compactMap { Int($0) }

        let input = TravelWhoViewModel.Input(
            paxInput: paxInput,
            prevButtonTapped: rootView.previousButton.rx.tap.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

//        output.isNextEnabled
//            .map { !$0 }
//            .drive(rootView.nextButton.rx.isHidden)
//            .disposed(by: disposeBag)

        output.navigateToPrev
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.onPrev?()
            })
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.onNext?()
            })
            .disposed(by: disposeBag)
    }
}
