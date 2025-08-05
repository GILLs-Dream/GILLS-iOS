//
//  TabBarViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/14/25.
//

import UIKit

enum AppTab: String, CaseIterable {
    case map, plane, list, mypage

    init?(index: Int) {
        switch index {
        case 0: self = .map
        case 1: self = .plane
        case 2: self = .list
        case 3: self = .mypage
        default: return nil
        }
    }

    func pageOrderNumber() -> Int {
        switch self {
        case .map: return 0
        case .plane: return 1
        case .list: return 2
        case .mypage: return 3
        }
    }

    var selectedImage: UIImage {
        switch self {
        case .map: return .icMapFill
        case .plane: return .icPlane
        case .list: return .icListFill
        case .mypage: return .icAccount
        }
    }

    var unselectedImage: UIImage {
        switch self {
        case .map: return .icMap
        case .plane: return .icPlane
        case .list: return .icList
        case .mypage: return .icAccount
        }
    }
}

final class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpStyle()
        delegate = self
    }

    private func setUpStyle() {
        tabBar.backgroundColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true
        tabBar.tintColor = .mainBlue
        tabBar.unselectedItemTintColor = .white
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 동일 탭이 재탭된 경우 확인
        if let nav = viewController as? UINavigationController {
            nav.popToRootViewController(animated: true)
        }
    }
}
