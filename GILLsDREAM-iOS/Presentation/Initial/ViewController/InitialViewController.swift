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
                // 임시
                let profileVC = ProfileViewController()
                self?.navigationController?.pushViewController(profileVC, animated: true)
            })
            .disposed(by: disposeBag)

        output.navigateToAppleSignUp
            .drive(onNext: { [weak self] in
                // 임시
                let profileVC = ProfileViewController()
                self?.navigationController?.pushViewController(profileVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
