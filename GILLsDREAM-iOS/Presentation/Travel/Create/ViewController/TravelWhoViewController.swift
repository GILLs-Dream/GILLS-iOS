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
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isNextEnabled
            .map { !$0 }
            .drive(rootView.nextButton.rx.isHidden)
            .disposed(by: disposeBag)

        output.navigateToNext
            .drive(onNext: { [weak self] in
                let nextVC = TravelWhoViewController()
                nextVC.view.backgroundColor = .white
                self?.navigationController?.pushViewController(nextVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
