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
        let loginType = UserDefaultsManager.shared.loginType
        let hasToken = KeychainManager.shared.accessToken != nil
        let isLogin = UserDefaultsManager.shared.isLogin
        let isOnboarded = UserDefaultsManager.shared.isOnboarding

        if loginType == "guest" {
            showTabBarFlow(isGuest: true)
            return
        }

        if !hasToken || !isLogin || !isOnboarded {
            showLoginFlow()
            return
        }
        showTabBarFlow()
    }
    
    func showLoginFlow() {
        let loginCoordinator = LoginCoordinator(navigationController)
        loginCoordinator.finishDelegate = self
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }

    func showTabBarFlow(isGuest: Bool = false) {
        let tabCoordinator = TabBarCoordinator(navigationController)
        tabCoordinator.finishDelegate = self
        childCoordinators.append(tabCoordinator)

        if isGuest {
            tabCoordinator.startGuestMode()
        } else {
            tabCoordinator.start()
        }
    }
}

// MARK: Finish Delegate Handling
extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === childCoordinator }
        
        switch childCoordinator.type {
        case .login:
            if UserDefaultsManager.shared.loginType == "guest" {
                showTabBarFlow(isGuest: true)
            } else if UserDefaultsManager.shared.isOnboarding {
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
