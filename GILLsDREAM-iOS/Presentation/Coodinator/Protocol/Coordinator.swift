//
//  Coordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set } // 하위 코디네이터 관리
    var navigationController: UINavigationController { get set }
    
    func start() // 코디네이터의 시작화면 표시

    init(navigationController: UINavigationController)
}
