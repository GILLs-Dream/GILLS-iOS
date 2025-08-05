//
//  TabBarCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

protocol TabBarCoordinatorProtocol: Coordinator {
    var tabBarController: UITabBarController { get set }
    func selectPage(_ page: AppTab)
    func setSelectedIndex(_ index: Int)
    func currentPage() -> AppTab?
}

final class TabBarCoordinator: NSObject, Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    var type: CoordinatorType { .tab }
    private var mainHomeCoordinator: MainHomeCoordinator?


    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = TabBarViewController()
    }
    
    func start() {
        let tabs: [AppTab] = [.map, .plane, .list, .mypage]
        let controllers: [UINavigationController] = tabs.map { getTabController(for: $0) }
        prepareTabBarController(with: controllers)
    }

    private func prepareTabBarController(with controllers: [UIViewController]) {
        tabBarController.setViewControllers(controllers, animated: false)
        tabBarController.selectedIndex = AppTab.plane.rawValueIndex
        navigationController.setViewControllers([tabBarController], animated: false)
    }

    private func getTabController(for tab: AppTab) -> UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)
        
        let rootVC: UIViewController

        switch tab {
        case .map:
            rootVC = MainHomeViewController() // mapCoordinator 구현 후 변경

        case .plane:
            let coordinator = MainHomeCoordinator(navController)
            coordinator.finishDelegate = self.finishDelegate
            childCoordinators.append(coordinator)
            mainHomeCoordinator = coordinator
            coordinator.start()
            return configureTabBar(navController, for: tab)

        case .list:
            rootVC = PlanListViewController()

        case .mypage:
            let myPageVC = MyPageViewController()
            myPageVC.onLogout = { [weak self] in
                guard let self = self else { return }
                self.tabBarController.viewControllers?.forEach {
                    if let nav = $0 as? UINavigationController {
                        nav.popToRootViewController(animated: false)
                    }
                }
                self.navigationController.setViewControllers([], animated: false)
                self.finish()
            }
            rootVC = myPageVC
        }

        navController.setViewControllers([rootVC], animated: false)
        return configureTabBar(navController, for: tab)
    }
    
    private func configureTabBar(_ navController: UINavigationController, for tab: AppTab) -> UINavigationController {
        navController.tabBarItem = UITabBarItem(title: "",
                                                image: tab.unselectedImage,
                                                selectedImage: tab.selectedImage)
        return navController
    }
}

private extension AppTab {
    var rawValueIndex: Int {
        return AppTab.allCases.firstIndex(of: self) ?? 0
    }
}
