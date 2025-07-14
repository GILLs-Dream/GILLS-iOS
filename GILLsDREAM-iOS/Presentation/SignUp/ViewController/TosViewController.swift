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
    private let viewModel = TosViewModel()
    
    
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
        
        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let vc = SignUpCompleteViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindDetailButtonActions() {
        rootView.serviceAgreementView.detailButton.rx.tap
            .bind { [weak self] in self?.presentDetail(title: "서비스 이용약관", content: TermsContent.service) }
            .disposed(by: disposeBag)

        rootView.personalAgreementView.detailButton.rx.tap
            .bind { [weak self] in self?.presentDetail(title: "개인정보 수집/이용 동의", content: TermsContent.personal) }
            .disposed(by: disposeBag)

        rootView.marketingAgreementView.detailButton.rx.tap
            .bind { [weak self] in self?.presentDetail(title: "마케팅 정보 수신 동의", content: TermsContent.marketing) }
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
