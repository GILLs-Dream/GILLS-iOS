//
//  TabBarCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

final class TabBarCoordinator: NSObject, Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    var type: CoordinatorType { .tab }
    private var mainHomeCoordinator: MainHomeCoordinator?
    
    private var isGuestMode = false
    private var currentTabs: [AppTab] = []
    private var vcToTab: [ObjectIdentifier: AppTab] = [:] // vc -> tab 매핑
    private weak var currentModal: CustomModalView?
    
    required init(_ nav: UINavigationController) {
        self.navigationController = nav
        self.tabBarController = TabBarViewController()
        super.init()
        self.tabBarController.delegate = self
    }

    func start() {
        isGuestMode = false
        let tabs: [AppTab] = [.list, .plane, .mypage]

        vcToTab.removeAll()
        currentTabs = tabs

        let controllers: [UINavigationController] = currentTabs.map { getTabController(for: $0) }
        prepareTabBarController(with: controllers)

        let planeIdx = currentTabs.firstIndex(of: .plane) ?? 0
        tabBarController.selectedIndex = planeIdx
        DispatchQueue.main.async { [weak self] in
            self?.tabBarController.selectedIndex = planeIdx
        }
    }

    func startGuestMode() {
        isGuestMode = true
        let tabs: [AppTab] = [.list, .plane, .mypage]

        vcToTab.removeAll()
        currentTabs = tabs

        let controllers: [UINavigationController] = currentTabs.map { getTabController(for: $0) }
        prepareTabBarController(with: controllers)

        let planeIdx = currentTabs.firstIndex(of: .plane) ?? 0
        tabBarController.selectedIndex = planeIdx
        DispatchQueue.main.async { [weak self] in
            self?.tabBarController.selectedIndex = planeIdx
        }
    }
    
    private func prepareTabBarController(with controllers: [UIViewController]) {
        tabBarController.setViewControllers(controllers, animated: false)
        navigationController.setViewControllers([tabBarController], animated: false)
    }
    
    private func getTabController(for tab: AppTab) -> UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)
        
        switch tab {
        case .map:
            let root = MainHomeViewController()
            navController.setViewControllers([root], animated: false)
            
        case .plane:
            let coordinator = MainHomeCoordinator(navController)
            coordinator.finishDelegate = self.finishDelegate
            coordinator.onRequestSignup = { [weak self] in
                guard let self else { return }
                self.finish()
            }
            childCoordinators.append(coordinator)
            mainHomeCoordinator = coordinator
            coordinator.start()

        case .list:
            let listVC = PlanListViewController()
            listVC.onSelectPlan = { [weak self] planId in
                let vc = TravelResultViewController(planId: planId)
                vc.shouldHideSaveButton = true
                self?.navigationController.pushViewController(vc, animated: false)
            }
            navController.setViewControllers([listVC], animated: false)

        case .mypage:
            let myPageVC = MyPageViewController()
            myPageVC.onLogout = { [weak self] in
                guard let self else { return }
                self.tabBarController.viewControllers?
                    .compactMap { $0 as? UINavigationController }
                    .forEach { $0.popToRootViewController(animated: false) }
                self.navigationController.setViewControllers([], animated: false)
                self.finish()
            }
            navController.setViewControllers([myPageVC], animated: false)
        }

        vcToTab[ObjectIdentifier(navController)] = tab
        return configureTabBar(navController, for: tab)
    }
    
    private func configureTabBar(_ navController: UINavigationController, for tab: AppTab) -> UINavigationController {
        navController.tabBarItem = UITabBarItem(title: "",
                                                image: tab.unselectedImage,
                                                selectedImage: tab.selectedImage)
        return navController
    }
    
    private func presentGuestSignupModal() {
        if currentModal != nil { return }
        let modal = CustomModalView(
            title: "회원가입이 필요한 기능입니다.\n회원가입 하시겠습니까?",
            confirmTitle: "예"
        )
        modal.alpha = 0
        modal.frame = tabBarController.view.bounds
        modal.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        modal.onConfirm = { [weak self] in
            guard let self else { return }
            self.currentModal = nil
            self.finish() // showLoginFlow()
        }
        modal.onCancel = { [weak self] in
            guard let self else { return }
            self.currentModal = nil
            let planeIdx = self.currentTabs.firstIndex(of: .plane) ?? 0
            self.tabBarController.selectedIndex = planeIdx
            if let nav = self.tabBarController.viewControllers?[planeIdx] as? UINavigationController {
                nav.popToRootViewController(animated: false)
            }
        }
        
        tabBarController.view.addSubview(modal)
        currentModal = modal
        UIView.animate(withDuration: 0.2) { modal.alpha = 1 }
    }
}

extension TabBarCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tbc: UITabBarController, shouldSelect vc: UIViewController) -> Bool {
        let key = ObjectIdentifier(vc)
        let tab = vcToTab[key]
        print("DBG shouldSelect vc=\(vc) tab=\(String(describing: tab)) guest=\(isGuestMode)")

        if isGuestMode, let tab, (tab == .list || tab == .mypage) {
            presentGuestSignupModal()
            return false
        }
        return true
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
