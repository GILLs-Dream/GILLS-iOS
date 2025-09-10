//
//  SignUpCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit
import RxSwift

final class SignUpCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .signup }
    private let flowViewModel = SignupFlowViewModel()

    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showProfileVC()
    }

    private func showProfileVC() {
        let vc = ProfileViewController(flowViewModel: flowViewModel)
        vc.onNext = { [weak self] in
            guard let self = self else { return }
            self.showTosVC()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showTosVC() {
        let vc = TosViewController(flowViewModel: flowViewModel)
        vc.onDetail = { [weak self] termsContent in
            guard let self = self else { return }
            self.showTosDetailVC(termsContent: termsContent)
        }
        vc.onCompleteSuccess = { [weak self] in
            self?.showSignupCompleteVC()
        }

        vc.onCompleteFailed = { [weak self] in
            guard let self else { return }
            self.resetFlow()

            let initial = InitialViewController()
            initial.onLogin = { [weak self] in
                self?.resetFlow()
                self?.showProfileVC()
            }
            self.navigationController.presentedViewController?.dismiss(animated: false)
            self.navigationController.setViewControllers([initial], animated: true)
        }

        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showTosDetailVC(termsContent: TermsContent) {
        let viewModel = TosDetailViewModel(title: termsContent.title, content: termsContent.content)
        let vc = TosDetailViewController(viewModel: viewModel)
        vc.onDismiss = { [weak self] in
            guard let self = self else { return }
            self.navigationController.popViewController(animated: true)
        }
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(vc, animated: true)
    }

    private func showSignupCompleteVC() {
        let vc = SignUpCompleteViewController()
        vc.onDone = { [weak self] in
            guard let self = self else { return }
            self.finish()
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func resetFlow() {
        flowViewModel.nickname = ""
        flowViewModel.profileImage = nil
        flowViewModel.marketingAgreement = false
    }
}
