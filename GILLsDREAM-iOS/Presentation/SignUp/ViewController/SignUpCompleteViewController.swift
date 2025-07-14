//
//  SignUpCompleteViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import UIKit
import RxSwift

class SignUpCompleteViewController: UIViewController {
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let rootView = SignUpCompleteView()
    private let viewModel = SignUpCompleteViewModel()
    
    
    // MARK: Life Cycle
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .mainBlue
        configureCustomNavigationBar()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = SignUpCompleteViewModel.Input(
            completeButtonTapped: rootView.completeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.navigateToHome
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let vc = TabBarViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
