//
//  TabBarCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

//protocol TabBarCoordinator: Coordinator {
//    var tabBarController: UITabBarController { get set }
//    func selectPage(_ page: TabBarPage)
//    func setSelectedIndex(_ index: Int)
//    func currentPage() -> TabBarPage?
//}

protocol TabBarCoordinatorProtocol: Coordinator {
    func showTabBarViewController()
}

final class TabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showTabBarViewController()
    }
    
    func showTabBarViewController() {
    }
}
