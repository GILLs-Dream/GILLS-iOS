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
    private let rootView: TravelWhenView
    private let viewModel: TravelWhenViewModel
    private let flowViewModel: TravelRequestFlowViewModel
    private let disposeBag = DisposeBag()
    var onNext: (() -> Void)?
    
    init(flowViewModel: TravelRequestFlowViewModel) {
        self.flowViewModel = flowViewModel
        self.rootView = TravelWhenView(titleText: flowViewModel.moodSummary)
        self.viewModel = TravelWhenViewModel(planId: flowViewModel.planId)
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
        pendingControl()
    }
    
    private func bindFlowViewModel() {
        if let travelDays = flowViewModel.travelDays.value {
            rootView.travelDurationView.startField.textField.text = "\(travelDays)"
        }
        
        if let startDate = flowViewModel.startDate.value {
            rootView.travelDateView.startField.textField.text = "\(startDate)"
        }
        
        if let endDate = flowViewModel.endDate.value {
            rootView.travelDateView.endField?.textField.text = "\(endDate)"
        }
        
        if flowViewModel.datePending.value {
            rootView.pendingButton.isSelected = true
        }
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
        
        output.calculatedEndDate
            .drive(onNext: { [weak self] endDate in
                guard let self = self else { return }
                if let startDateText = self.rootView.travelDateView.startField.textField.text,
                   !startDateText.isEmpty {
                    self.rootView.travelDateView.endField?.updateText(endDate.formatted("yyyy년 M월 d일"))
                }
            })
            .disposed(by: disposeBag)
        
        output.calculatedStartDate
            .drive(onNext: { [weak self] startDate in
                self?.rootView.travelDateView.startField.updateText(startDate.formatted("yyyy년 M월 d일"))
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
        
        output.isLoading
            .drive(onNext: { [weak self] loading in
                guard let self else { return }
                self.rootView.nextButton.isEnabled = !loading
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(onNext: { ToastManager.shared.show(message: $0) })
            .disposed(by: disposeBag)

        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.flowViewModel.travelDays.accept(self.viewModel.travelDays)
                self.flowViewModel.startDate.accept(self.viewModel.startDate)
                self.flowViewModel.endDate.accept(self.viewModel.endDate)
                self.flowViewModel.datePending.accept(self.viewModel.datePending)
                self.onNext?()
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
