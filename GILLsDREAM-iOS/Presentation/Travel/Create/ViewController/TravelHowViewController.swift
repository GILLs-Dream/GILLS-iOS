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
    private let disposeBag = DisposeBag()
    var onPrev: (() -> Void)?
    var onComplete: (() -> Void)?

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
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
                self?.onPrev?()
            })
            .disposed(by: disposeBag)

        output.navigateToNext
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.rootView.lottieView.startAnimating()
            })
            .delay(.milliseconds(3000), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.rootView.lottieView.stopAnimating()
                self.onComplete?()
            })
            .disposed(by: disposeBag)
    }
}
