//
//  MainHomeViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/17/25.
//

import UIKit
import RxSwift

class MainHomeViewController: BaseViewController {

    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let rootView = MainHomeView()
    private let viewModel = MainHomeViewModel()
    var onStart: (() -> Void)?
    var onHome: (() -> Void)?

    // MARK: Life Cycle
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    //MARK: View Model
    private func bindViewModel() {
        let input = MainHomeViewModel.Input(
            viewWillAppear: rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map { _ in () },
            buttonTapped: rootView.travelButton.rx.tap.asObservable(),
            homeButtonTapped: rootView.topBarView.homeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        let isGuest = UserDefaultsManager.shared.loginType == "guest"
        
        output.nickname
            .drive(onNext: { [weak self] name in
                let displayName = isGuest ? "길동이" : (name.isEmpty ? "길동이" : name)
                self?.rootView.topBarView.apply(nickname: displayName)
            })
            .disposed(by: disposeBag)
        
        output.navigateToRequest
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.onStart?()
            })
            .disposed(by: disposeBag)
        
        output.navigateToHome
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                print("💚💚💚💚💚")
                self.onHome?()
            })
            .disposed(by: disposeBag)
    }
}
