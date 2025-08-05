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

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        let input = MyPageViewModel.Input(
            serviceTapped: rootView.serviceButton.rx.tap.asObservable(),
            withdrawTapped: rootView.withdrawButton.rx.tap.asObservable(),
            logoutTapped: rootView.logoutButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.showServiceTerms
            .bind { [weak self] in
                guard let self = self else { return }
                self.presentDetail(title: "서비스 이용약관", content: TermsContent.service.content)
            }
            .disposed(by: disposeBag)

        output.showWithdrawModal
            .bind { [weak self] in
                guard let self = self else { return }
                self.presentConfirmModal(
                    title: "정말로 길동이의 꿈을\n탈퇴하시겠습니까?",
                    confirmTitle: "탈퇴",
                    confirmAction: {
                        // TODO: 회원탈퇴 API 연결
                    }
                )
            }
            .disposed(by: disposeBag)

        output.showLogoutModal
            .bind { [weak self] in
                guard let self = self else { return }
                self.presentConfirmModal(
                    title: "로그아웃 하시겠습니까?",
                    confirmTitle: "로그아웃",
                    confirmAction: {
                        // TODO: 로그아웃 API 연결 후 InitialVC로 이동
                    }
                )
            }
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
