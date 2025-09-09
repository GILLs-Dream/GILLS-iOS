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

    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showProfileVC()
    }

    private func showProfileVC() {
        let vc = ProfileViewController()
        vc.onNext = { [weak self] in
            guard let self = self else { return }
            self.showTosVC()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showTosVC() {
        let vc = TosViewController(flowViewModel: SignupFlowViewModel())
        vc.onDetail = { [weak self] termsContent in
            guard let self = self else { return }
            self.showTosDetailVC(termsContent: termsContent)
        }
        vc.onComplete = { [weak self] in
            guard let self = self else { return }
            self.showSignupCompleteVC()
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
            UserDefaultsManager.shared.isOnboarding = true
            self.finish()
        }
        navigationController.pushViewController(vc, animated: true)
    }
}
