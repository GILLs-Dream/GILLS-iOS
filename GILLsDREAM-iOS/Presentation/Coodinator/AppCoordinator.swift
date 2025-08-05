//
//  AppCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType { .app }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if isValidToken() {
            showTabBarFlow()
        } else {
            showTabBarFlow() //showLoginFlow()
        }
    }
    
    private func isValidToken() -> Bool {
        return UserDefaultsManager.shared.isLogin
    }

    func showLoginFlow() {
        let loginCoordinator = LoginCoordinator(navigationController)
        loginCoordinator.finishDelegate = self
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }

    func showTabBarFlow() {
        let tabCoordinator = TabBarCoordinator(navigationController)
        tabCoordinator.finishDelegate = self
        childCoordinators.append(tabCoordinator)
        tabCoordinator.start()
    }
}

// MARK: Finish Delegate Handling
extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === childCoordinator }

        switch childCoordinator.type {
        case .login:
            if UserDefaultsManager.shared.isOnboarding {
                showTabBarFlow()
            } else {
                showLoginFlow()
            }
        case .signup, .main:
            showTabBarFlow()
        case .tab:
            showLoginFlow()
        default:
            break
        }
    }
}
