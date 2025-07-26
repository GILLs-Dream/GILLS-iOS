//
//  AppCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

protocol AppCoordinatorProtocol: Coordinator {
    func showLoginFlow()
    func showTabBarFlow()
}

final class AppCoordinator: AppCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
        
    func start() {
        if isValidToken() {
            showTabBarFlow()
        } else {
            showLoginFlow()
        }
    }

    private func isValidToken() -> Bool {
        guard UserDefaultsManager.shared.isLogin else { return false }
        // TODO: 토큰 만료 여부 체크
        return true // 임시 반환
    }

    func showLoginFlow() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }

    func showTabBarFlow() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
}
