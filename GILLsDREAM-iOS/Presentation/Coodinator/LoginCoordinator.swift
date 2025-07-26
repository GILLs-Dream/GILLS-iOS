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
    func showSignUpController()
}

final class LoginCoordinator: Coordinator {
    var delegate: LoginCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let initialViewController = InitialViewController()
        initialViewController.coordinator = self
        navigationController.pushViewController(initialViewController, animated: true)
    }
    
    func kakaoLogin() {
        delegate?.didKakaoLoggedIn(self)
    }
    
    func appleLogin() {
        delegate?.didAppleLoggedIn(self)
    }
    
    
}
