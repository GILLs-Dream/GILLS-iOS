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
    var onNeedOnboarding: (() -> Void)?

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

        output.showMain
            .emit(onNext: { [weak self] in self?.onLogin?() })
            .disposed(by: disposeBag)

        output.showOnboarding
            .emit(onNext: { [weak self] in self?.onNeedOnboarding?() })
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                guard let self else { return }
                rootView.kakaoButton.isEnabled = !isLoading
                rootView.appleButton.isEnabled = !isLoading

                let host = self.tabBarController?.view ?? self.view
                if isLoading {
                    LoadingOverlayView.shared.updateText("로그인 중입니다.")
                    LoadingOverlayView.shared.show(in: host!)
                    self.view.isUserInteractionEnabled = false
                } else {
                    LoadingOverlayView.shared.hide()
                    self.view.isUserInteractionEnabled = true
                }
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(onNext: { message in
                ToastManager.shared.show(message: message)
            })
            .disposed(by: disposeBag)
    }
}
