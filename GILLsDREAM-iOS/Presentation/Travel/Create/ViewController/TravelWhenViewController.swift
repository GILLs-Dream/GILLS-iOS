//
//  TravelWhenViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/16/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelWhenViewController: TravelViewController {
    private let rootView = TravelWhenView()
    private let viewModel = TravelWhenViewModel()
    private let disposeBag = DisposeBag()
    
    private var isPending = false

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        pendingControl()
    }

    private func bindViewModel() {
        rootView.headerView.currentStep = 0

        let travelDays = rootView.travelDurationView.startField.textField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(rootView.travelDurationView.startField.textField.rx.text.orEmpty)
            .compactMap { Int($0) }

        let startDate = rootView.travelDateView.startField.textField.rx
            .controlEvent(.editingDidEnd)
            .map { self.rootView.travelDateView.startField.selectedDate }
            .compactMap { $0 }
        
        let endDate = rootView.travelDateView.endField!.textField.rx
            .controlEvent(.editingDidEnd)
            .map { self.rootView.travelDateView.endField!.selectedDate }
            .compactMap { $0 }

        let input = TravelWhenViewModel.Input(
            travelDaysInput: travelDays,
            startDateInput: startDate,
            endDateInput: endDate,
            pendingButtonTapped: rootView.pendingButton.rx.tap.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isNextEnabled
            .map { !$0 }
            .drive(rootView.nextButton.rx.isHidden)
            .disposed(by: disposeBag)

        output.calculatedEndDate
            .drive(onNext: { [weak self] endDate in
                guard let self = self else { return }
                if let startDateText = self.rootView.travelDateView.startField.textField.text,
                   !startDateText.isEmpty {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ko_KR")
                    formatter.dateFormat = "yyyy년  M월  d일"
                    self.rootView.travelDateView.endField?.updateText(formatter.string(from: endDate))
                }
            })
            .disposed(by: disposeBag)
        
        output.calculatedStartDate
            .drive(onNext: { [weak self] startDate in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "yyyy년  M월  d일"
                self?.rootView.travelDateView.startField.updateText(formatter.string(from: startDate))
            })
            .disposed(by: disposeBag)
        
        output.isPending
            .drive(onNext: { [weak self] isPending in
                guard let self = self else { return }
                if isPending {
                    self.rootView.pendingButton.setImage(.imgCheckedCircle, for: .normal)
                    self.rootView.travelDateView.startField.updateText(nil)
                    self.rootView.travelDateView.endField?.updateText(nil)
                } else {
                    self.rootView.pendingButton.setImage(.imgCircle, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .asObservable()
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                let nextVC = TravelWhoViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func pendingControl() {
        rootView.travelDateView.startField.onTappedWhilePending = { [weak self] in
            self?.viewModel.handleDateFieldTapped {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self?.rootView.travelDateView.startField.textField.becomeFirstResponder()
                }
            }
        }

        rootView.travelDateView.endField?.onTappedWhilePending = { [weak self] in
            self?.viewModel.handleDateFieldTapped {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self?.rootView.travelDateView.endField?.textField.becomeFirstResponder()
                }
            }
        }
    }
}
