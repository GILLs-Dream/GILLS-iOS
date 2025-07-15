//
//  TabBarViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/14/25.
//

import UIKit

enum AppTab: String, CaseIterable {
    case map
    case explore
    case plane
    case group
    case list
    
    var selectedImage: UIImage {
        switch self {
        case .map: return .icMapFill
        case .explore: return .icExploreFill
        case .plane: return .icPlane
        case .group: return .icGroupFill
        case .list: return .icListFill
        }
    }
    
    var unselectedImage: UIImage {
        switch self {
        case .map: return .icMap
        case .explore: return .icExplore
        case .plane: return .icPlane
        case .group: return .icGroup
        case .list: return .icList
        }
    }
}

final class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    // MARK: Life Cycle - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpStyle()
    }
    
    // MARK: setUpView
    private func setUpView() {
        
        let mapVC = UINavigationController(rootViewController: MainHomeViewController())
        let exploreVC = UINavigationController(rootViewController: MainHomeViewController())
        let createPlanVC = UINavigationController(rootViewController: MainHomeViewController())
        let groupVC = UINavigationController(rootViewController: MainHomeViewController())
        let planListVC = UINavigationController(rootViewController: MainHomeViewController())

        let viewControllerList = [
            mapVC,
            exploreVC,
            createPlanVC,
            groupVC,
            planListVC
        ]
        
        viewControllerList.enumerated().forEach { index, viewController in
            let tab = AppTab.allCases[index]
            viewController.tabBarItem = UITabBarItem(title: "",
                                                     image: tab.unselectedImage,
                                                     selectedImage: tab.selectedImage)
        }
        self.setViewControllers(viewControllerList, animated: false)
    }
    
    // MARK: setUpStyle
    private func setUpStyle() {
        self.tabBar.backgroundColor = .clear
        self.tabBar.barTintColor = .white
        self.tabBar.tintColor = .mainBlue
        self.tabBar.unselectedItemTintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
