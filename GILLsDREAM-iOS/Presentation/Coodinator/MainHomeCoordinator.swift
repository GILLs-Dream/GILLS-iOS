//
//  MainHomeCoordinator.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/29/25.
//

import UIKit

final class MainHomeCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .main }
    private let flowViewModel = TravelRequestFlowViewModel()
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainHomeVC()
    }
    
    func showMainHomeVC() {
        let vc = MainHomeViewController()
        vc.onStart = { [weak self] in
            self?.showTravelRequestVC()
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showTravelRequestVC() {
        let vc = TravelRequestViewController()
        vc.onNext = { [weak self] in
            self?.showTravelWhenVC()
        }
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showTravelWhenVC() {
        let vc = TravelWhenViewController(flowViewModel: flowViewModel)
        vc.onNext = { [weak self] in
            self?.showTravelWhoVC()
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showTravelWhoVC() {
        let vc = TravelWhoViewController()
        vc.onNext = { [weak self] in
            self?.showTravelWhereVC()
        }
        vc.onPrev = { [weak self] in
            self?.navigationController.popViewController(animated: false)
        }
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showTravelWhereVC() {
        let vc = TravelWhereViewController()
        vc.onNext = { [weak self] in
            self?.showTravelHowVC()
        }
        vc.onPrev = { [weak self] in
            self?.navigationController.popViewController(animated: false)
        }
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showTravelHowVC() {
        let vc = TravelHowViewController()
        vc.onComplete = { [weak self] in
            self?.showTravelResultVC()
        }
        vc.onPrev = { [weak self] in
            self?.navigationController.popViewController(animated: false)
        }
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showTravelResultVC() {
        let vc = TravelRequestViewController() // TODO: TravelResultVC 구현 후 변경
        navigationController.pushViewController(vc, animated: true)
    }
}
