//
//  InitialViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 6/3/25.
//

import UIKit
import RxSwift
import RxCocoa
import AuthenticationServices

final class InitialViewController: UIViewController {
    var onLogin: (() -> Void)?

    private let disposeBag = DisposeBag()
    private let rootView = InitialView()
    private let viewModel = InitialViewModel()
    
    // MARK: Life Cycle
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = InitialViewModel.Input(
            kakaoButtonTapped: rootView.kakaoButton.rx.tap.asObservable(),
            appleButtonTapped: rootView.appleButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.loginSucceeded
            .emit(onNext: { [weak self] in
                self?.onLogin?()
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] loading in
                guard let self else { return }
                self.rootView.kakaoButton.isEnabled = !loading
                self.rootView.appleButton.isEnabled = !loading
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(onNext: { message in
                ToastManager.shared.show(message: message)
            })
            .disposed(by: disposeBag)
    }
}
