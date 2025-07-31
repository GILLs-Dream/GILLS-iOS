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
        let pages: [AppTab] = [.map, .plane, .list]
            .sorted(by: {
                $0.pageOrderNumber() < $1.pageOrderNumber()
            })
        let controllers: [UINavigationController] = pages.map(getTabController)
        prepareTabBarController(withTabControllers: controllers)
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = AppTab.plane.pageOrderNumber()
        navigationController.viewControllers = [tabBarController]
    }
    
    private func getTabController(_ page: AppTab) -> UINavigationController {
        let navController = UINavigationController()
        navController.tabBarItem = UITabBarItem(title: "",
                                                image: page.unselectedImage,
                                                selectedImage: page.selectedImage)
        
        switch page {
        case .map:
            let mapVC = MainHomeViewController()
            navController.setViewControllers([mapVC], animated: false)
            
        case .plane:
            let mainHomeCoordinator = MainHomeCoordinator(navController)
            self.mainHomeCoordinator = mainHomeCoordinator
            mainHomeCoordinator.start()
            childCoordinators.append(mainHomeCoordinator)
            
        case .list:
            let listVC = MainHomeViewController()
            navController.setViewControllers([listVC], animated: false)
        }
        return navController
    }
    
    func currentPage() -> AppTab? {
        AppTab(index: tabBarController.selectedIndex)
    }
    
    func selectPage(_ page: AppTab) {
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = AppTab(index: index) else { return }
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
}
