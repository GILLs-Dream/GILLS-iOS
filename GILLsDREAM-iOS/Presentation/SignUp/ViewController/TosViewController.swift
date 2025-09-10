//
//  TosViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/10/25.
//

import UIKit
import RxSwift

class TosViewController: UIViewController {
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let rootView = TosView()
    var onDetail: ((TermsContent) -> Void)?
    var onCompleteSuccess: (() -> Void)?
    var onCompleteFailed: (() -> Void)?
    
    private let flowViewModel: SignupFlowViewModel
    private let viewModel: TosViewModel
    
    init(flowViewModel: SignupFlowViewModel) {
        self.flowViewModel = flowViewModel
        self.viewModel = TosViewModel(flowmodel: flowViewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .mainBlue
        configureCustomNavigationBar()
        bindViewModel()
        bindDetailButtonActions()
    }
    
    private func bindViewModel() {
        let input = TosViewModel.Input(
            allAgreeTapped: rootView.allAgreeAgreementView.checkButton.rx.tap.asObservable(),
            serviceTapped: rootView.serviceAgreementView.checkButton.rx.tap.asObservable(),
            personalTapped: rootView.personalAgreementView.checkButton.rx.tap.asObservable(),
            marketingTapped: rootView.marketingAgreementView.checkButton.rx.tap.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.allChecked
            .drive(onNext: { [weak self] isSelected in
                guard let self = self else { return }
                self.rootView.allAgreeAgreementView.updateCheckState(isSelected: isSelected)
            })
            .disposed(by: disposeBag)
        
        output.serviceChecked
            .drive(onNext: { [weak self] isSelected in
                guard let self = self else { return }
                self.rootView.serviceAgreementView.updateCheckState(isSelected: isSelected)
            })
            .disposed(by: disposeBag)
        
        output.personalChecked
            .drive(onNext: { [weak self] isSelected in
                guard let self = self else { return }
                self.rootView.personalAgreementView.updateCheckState(isSelected: isSelected)
            })
            .disposed(by: disposeBag)
        
        output.marketingChecked
            .drive(onNext: { [weak self] isSelected in
                guard let self = self else { return }
                self.rootView.marketingAgreementView.updateCheckState(isSelected: isSelected)
            })
            .disposed(by: disposeBag)
        
        output.isNextButtonEnabled
            .drive(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                self.rootView.updateNextButtonTheme(isAvailable: isEnabled)
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .emit(onNext: { ToastManager.shared.show(message: $0) })
            .disposed(by: disposeBag)
        
        output.completeSucceeded
            .emit(onNext: { [weak self] in self?.onCompleteSuccess?() })
            .disposed(by: disposeBag)

        output.completeFailed
            .emit(onNext: { [weak self] msg in
                ToastManager.shared.show(message: msg)
                self?.onCompleteFailed?()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindDetailButtonActions() {
        rootView.serviceAgreementView.detailButton.rx.tap
            .bind { [weak self] in self?.onDetail?(.service) }
            .disposed(by: disposeBag)

        rootView.personalAgreementView.detailButton.rx.tap
            .bind { [weak self] in self?.onDetail?(.personal) }
            .disposed(by: disposeBag)

        rootView.marketingAgreementView.detailButton.rx.tap
            .bind { [weak self] in self?.onDetail?(.marketing) }
            .disposed(by: disposeBag)
    }

    private func presentDetail(title: String, content: String) {
        let viewModel = TosDetailViewModel(title: title, content: content)
        let vc = TosDetailViewController(viewModel: viewModel)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
}
