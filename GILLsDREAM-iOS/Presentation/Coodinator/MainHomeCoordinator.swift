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
        let vc = TravelRequestViewController(flowViewModel: flowViewModel)
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
        let vc = TravelWhoViewController(flowViewModel: flowViewModel)
        vc.onNext = { [weak self] in
            self?.showTravelHowVC()
            //TODO: Map 구현 후 변경
            //self?.showTravelWhereVC()
        }
        vc.onPrev = { [weak self] in
            self?.navigationController.popViewController(animated: false)
        }
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showTravelWhereVC() {
        let vc = TravelWhereViewController(flowViewModel: flowViewModel)
        vc.onNext = { [weak self] in
            self?.showTravelHowVC()
        }
        vc.onPrev = { [weak self] in
            self?.navigationController.popViewController(animated: false)
        }
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showTravelHowVC() {
        let vc = TravelHowViewController(flowViewModel: flowViewModel)
        vc.onComplete = { [weak self] in
            self?.showTravelResultVC()
        }
        vc.onPrev = { [weak self] in
            self?.navigationController.popViewController(animated: false)
        }
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showTravelResultVC() {
        let vc = TravelResultViewController(flowViewModel: flowViewModel)
        vc.onSave = { [weak self] in
            self?.showTravelSaveVC()
        }
        vc.onMap = { [weak self] items in
            self?.showMapModal(with: items)
        }
        navigationController.setViewControllers([vc], animated: false)
    }
    
    
    private func showTravelSaveVC() {
        let vc = TravelSaveViewController()
        vc.onComplete = { [weak self] in
            guard let self = self else { return }
            self.finish()
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showMapModal(with items: [PlaceResult]) {
        // TODO: 구현
    }
}
