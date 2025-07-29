//
//  TabBarCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .tab }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("✅ TabBarCoordinator started")
        let tabBarController = TabBarViewController()
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}
