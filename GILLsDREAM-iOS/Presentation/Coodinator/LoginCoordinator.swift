//
//  LoginCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

final class LoginCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .login }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showInitialVC()
    }
    
    private func showInitialVC() {
        let vc = InitialViewController()
        vc.onLogin = { [weak self] in
            self?.finish()
        }
        vc.onNeedOnboarding = { [weak self] in
            self?.startSignup()
        }
        navigationController.setViewControllers([vc], animated: false)
    }
    
    private func startSignup() {
        let signUpCoordinator = SignUpCoordinator(navigationController)
        signUpCoordinator.finishDelegate = self.finishDelegate
        childCoordinators.append(signUpCoordinator)
        signUpCoordinator.start()
    }
}

extension LoginCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === childCoordinator }
    }
}
