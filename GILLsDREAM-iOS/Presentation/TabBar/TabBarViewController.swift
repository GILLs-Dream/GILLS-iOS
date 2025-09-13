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

protocol TabReselectHandler: AnyObject {
    func handleTabReselect() // 같은 탭 더블탭시 호출 (스크롤 탑, 리프레시 등)
}

final class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    private var lastSelectedIndex: Int = -1
    private var lastTapTime: Date?

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
        let now = Date()
        let idx = selectedIndex

        // 더블탭 판단 (0.35초 이내 재탭)
        let isDoubleTap: Bool = (lastSelectedIndex == idx) && {
            if let last = lastTapTime { return now.timeIntervalSince(last) < 0.35 }
            return false
        }()

        if isDoubleTap {
            // 0) 선택된 탭의 내비 찾기
            let nav = (viewController as? UINavigationController)
                ?? (viewController as? UITabBarController)?.selectedViewController as? UINavigationController

            // 1) 탭별 공통: 먼저 popToRoot (list는 항상 PlanList로 복귀)
            nav?.popToRootViewController(animated: true)

            // 2) 루트/탑 VC에 “reselect” 알려서 원하는 리프레시 수행
            let receiver: TabReselectHandler? =
                (nav?.topViewController as? TabReselectHandler)
                ?? (nav?.viewControllers.first as? TabReselectHandler)
            receiver?.handleTabReselect()
        }

        lastSelectedIndex = idx
        lastTapTime = now
    }
}
