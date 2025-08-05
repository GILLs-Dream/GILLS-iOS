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
        let didSignUp = didSignUp()
        showInitialVC(didSignUp)
    }
    
    private func didSignUp() -> Bool {
        return UserDefaultsManager.shared.isOnboarding
    }
    
    private func showInitialVC(_ didSignUp: Bool) {
        let vc = InitialViewController()
        vc.onKakaoLogin = { [weak self] in
            if (didSignUp) { self?.finish() }
            self?.startLogin()
        }
        vc.onAppleLogin = { [weak self] in
            if (didSignUp) { self?.finish() }
            self?.startLogin()
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startLogin() {
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
