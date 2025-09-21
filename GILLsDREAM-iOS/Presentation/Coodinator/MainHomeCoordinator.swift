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
    private weak var currentModal: CustomModalView?
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
            presentGuestSignupModal()
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
    
    // 게스트용 커스텀 모달
    private func presentGuestSignupModal() {
        guard currentModal == nil else { return }
        
        let modal = CustomModalView(
            title: "여행을 저장하려면\n회원가입이 필요해요.\n진행하시겠습니까?",
            confirmTitle: "예"
        )
        
        let hostView = navigationController.view!
        modal.alpha = 0
        modal.frame = hostView.bounds
        modal.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        modal.onConfirm = { [weak self] in
            guard let self else { return }
            self.currentModal?.removeFromSuperview()
            self.currentModal = nil
            self.onRequestSignup?()
        }
        
        modal.onCancel = { [weak self] in
            guard let self else { return }
            self.currentModal?.removeFromSuperview()
            self.currentModal = nil
            self.showMainHomeVC()
        }
        
        hostView.addSubview(modal)
        currentModal = modal
        UIView.animate(withDuration: 0.2) { modal.alpha = 1 }
    }
    
    private func showMapModal(with items: [TimelineItem]) {
        // TODO: 구현
    }
}
