//
//  TabBarViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/14/25.
//

import UIKit

enum AppTab: String, CaseIterable {
    case map, plane, list

    init?(index: Int) {
        switch index {
        case 0: self = .map
        case 1: self = .plane
        case 2: self = .list
        default: return nil
        }
    }

    func pageOrderNumber() -> Int {
        switch self {
        case .map: return 0
        case .plane: return 1
        case .list: return 2
        }
    }

    var selectedImage: UIImage {
        switch self {
        case .map: return .icMapFill
        case .plane: return .icPlane
        case .list: return .icListFill
        }
    }

    var unselectedImage: UIImage {
        switch self {
        case .map: return .icMap
        case .plane: return .icPlane
        case .list: return .icList
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
        tabBar.barTintColor = .white
        tabBar.tintColor = .mainBlue
        tabBar.unselectedItemTintColor = .white
        tabBar.isTranslucent = false
    }
}
