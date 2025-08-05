//
//  LoginCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

protocol LoginCoordinatorDelegate {
    func didKakaoLoggedIn(_ coordinator: LoginCoordinator)
    func didAppleLoggedIn(_ coordinator: LoginCoordinator)
}

final class LoginCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var delegate: LoginCoordinatorDelegate?
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
        vc.onKakaoSignUp = { [weak self] in
            self?.startKakaoSignUp()
        }
        vc.onAppleSignUp = { [weak self] in
            self?.startAppleSignUp()
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func kakaoLogin() {
        delegate?.didKakaoLoggedIn(self)
        finish()
    }
    
    func appleLogin() {
        delegate?.didAppleLoggedIn(self)
        finish()
    }
    
    func startKakaoSignUp() {
        let signUpCoordinator = SignUpCoordinator(navigationController)
        signUpCoordinator.finishDelegate = self.finishDelegate
        childCoordinators.append(signUpCoordinator)
        signUpCoordinator.start()
    }
    
    func startAppleSignUp() {
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
