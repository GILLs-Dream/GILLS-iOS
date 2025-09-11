//
//  MyPageViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyPageViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let rootView = MyPageView()
    private let viewModel = MyPageViewModel()
    var onLogout: (() -> Void)?

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private let confirmLogoutRelay = PublishRelay<Void>()
    private let confirmWithdrawRelay = PublishRelay<Void>()
    
    private func bindViewModel() {
        let input = MyPageViewModel.Input(
            viewWillAppear: rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map { _ in () },
            serviceTapped: rootView.serviceButton.rx.tap.asObservable(),
            withdrawTapped: rootView.withdrawButton.rx.tap.asObservable(),
            logoutTapped: rootView.logoutButton.rx.tap.asObservable(),
            confirmLogout: confirmLogoutRelay.asObservable(),
            confirmWithdraw: confirmWithdrawRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.profile
            .drive(onNext: { [weak self] profile in
                self?.rootView.apply(profileImg: profile)
            })
            .disposed(by: disposeBag)
        
        output.nickname
            .drive(onNext: { [weak self] name in
                self?.rootView.apply(nickname: name)
            })
            .disposed(by: disposeBag)

        output.email
            .drive(onNext: { [weak self] email in
                self?.rootView.apply(email: email)
            })
            .disposed(by: disposeBag)
        
        output.showServiceTerms
            .emit(onNext: { [weak self] in
                guard let self else { return }
                self.presentDetail(title: "서비스 이용약관", content: TermsContent.service.content)
            })
            .disposed(by: disposeBag)
        
        // 로그아웃 모달
        output.showLogoutModal
            .emit(onNext: { [weak self] in
                self?.presentConfirmModal(
                    title: "로그아웃 하시겠습니까?",
                    confirmTitle: "로그아웃",
                    confirmAction: { self?.confirmLogoutRelay.accept(()) }
                )
            })
            .disposed(by: disposeBag)
        
        // 탈퇴 모달
        output.showWithdrawModal
            .emit(onNext: { [weak self] in
                self?.presentConfirmModal(
                    title: "정말 탈퇴하시겠습니까?",
                    confirmTitle: "탈퇴",
                    confirmAction: { self?.confirmWithdrawRelay.accept(()) }
                )
            })
            .disposed(by: disposeBag)
        
        // 성공 시 상위로 알려서 플로우 전환
        output.logoutSucceeded
            .emit(onNext: { [weak self] in
                ToastManager.shared.show(message: "로그아웃되었습니다.")
                self?.onLogout?()
            })
            .disposed(by: disposeBag)
        
        output.withdrawSucceeded
            .emit(onNext: { [weak self] in
                ToastManager.shared.show(message: "탈퇴가 완료되었습니다.")
                self?.onLogout?()
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .emit(onNext: { ToastManager.shared.show(message: $0) })
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

    private func presentConfirmModal(title: String, confirmTitle: String, confirmAction: @escaping () -> Void) {
        let modal = CustomModalView(title: title, confirmTitle: confirmTitle)
        modal.onConfirm = confirmAction
        view.addSubview(modal)
        modal.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
