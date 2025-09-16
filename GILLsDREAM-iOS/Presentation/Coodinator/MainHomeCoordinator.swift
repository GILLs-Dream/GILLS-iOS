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
    private var flowViewModel = TravelRequestFlowViewModel()
    var onRequestSignup: (() -> Void)?
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainHomeVC()
    }
    
    func showMainHomeVC() {
        flowViewModel = TravelRequestFlowViewModel()
        let vc = MainHomeViewController()
        vc.onStart = { [weak self] in self?.startNewTravelFlow() }

        vc.onHome = { [weak self] in
            self?.onRequestSignup?()
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func startNewTravelFlow() {  // 진입 직전에 한 번 더 안전하게 새로 생성
        flowViewModel = TravelRequestFlowViewModel()
        showTravelRequestVC()
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
        vc.onComplete = { [weak self] planId in
            self?.showTravelResultVC(planId: planId)
        }
        vc.onPrev = { [weak self] in
            self?.navigationController.popViewController(animated: false)
        }
        vc.onFail = { [weak self] in
            self?.showMainHomeVC()
        }
        navigationController.pushViewController(vc, animated: false)
    }

    private func showTravelResultVC(planId: Int) {
        let vc = TravelResultViewController(planId: planId)
        vc.onSave = { [weak self] in
            self?.showTravelSaveVC(planId: planId)
        }
        vc.onMap = { [weak self] items in
            self?.showMapModal(with: items)
        }
        navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showTravelSaveVC(planId: Int) {
        // 게스트
        if UserDefaultsManager.shared.loginType == "guest" {
            let alert = UIAlertController(
                title: "회원가입이 필요해요",
                message: "여행을 저장하려면 회원가입이 필요합니다. 지금 진행할까요?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: { [weak self] _ in
                self?.showMainHomeVC()   // 메인홈
            }))
            alert.addAction(UIAlertAction(title: "예", style: .default, handler: { [weak self] _ in
                self?.onRequestSignup?() // 탭 종료 -> 로그인/회원가입 플로우로
            }))
            navigationController.present(alert, animated: true)
            return
        }

        // 가입자
        let vc = TravelSaveViewController(planId: planId)
        vc.onComplete = { [weak self] in
            guard let self = self else { return }
            self.finish()
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showMapModal(with items: [TimelineItem]) {
        // TODO: 구현
    }
}
