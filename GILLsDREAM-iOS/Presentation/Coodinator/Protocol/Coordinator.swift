//
//  Coordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/25/25.
//

import UIKit

enum CoordinatorType {
    /// app : 앱 전반적인 로직을 담당하는 코디네이터
    case app
    /// login : initial 화면의 카카오, 애플 소셜로그인을 담당하는 코디네이터
    case login
    /// signup : 사용자가 최초 진입 시 사용자 정보입력 로직을 담당하는 코디네이터
    case signup
    /// tab : 앱 탭바 로직을 담당하는 코디네이터
    case tab
    /// main : 여행정보 입력, 생성, 결과 등 여행 생성 관련 로직을 담당하는 코디네이터
    case main
    /// mypage : 회원탈퇴 및 로그아웃을 담당하는 코디네이터
    case mypage
}

// MARK: Base Coordinator
protocol Coordinator: AnyObject {
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    var type: CoordinatorType { get }
    
    func start()
    func finish()
    
    init(_ navigationController: UINavigationController)
}

extension Coordinator {
    func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}
