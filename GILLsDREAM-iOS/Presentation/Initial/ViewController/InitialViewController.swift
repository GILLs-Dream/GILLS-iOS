//
//  InitialViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 6/3/25.
//

import UIKit
import RxSwift

final class InitialViewController: UIViewController {
    
    // MARK: Properties
    var onKakaoSignUp: (() -> Void)?
    var onAppleSignUp: (() -> Void)?
    
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

        output.navigateToKakaoSignUp
            .drive(onNext: { [weak self] in
                self?.onKakaoSignUp?()
            })
            .disposed(by: disposeBag)

        output.navigateToAppleSignUp
            .drive(onNext: { [weak self] in
                self?.onAppleSignUp?()
            })
            .disposed(by: disposeBag)
    }
}
