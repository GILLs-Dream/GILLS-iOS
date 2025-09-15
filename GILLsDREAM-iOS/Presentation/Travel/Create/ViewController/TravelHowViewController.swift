//
//  TravelHowViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelHowViewController: TravelViewController {
    private let rootView: TravelHowView
    private let viewModel: TravelHowViewModel
    private let flowViewModel: TravelRequestFlowViewModel
    private let disposeBag = DisposeBag()
    var onPrev: (() -> Void)?
    var onComplete: ((Int) -> Void)?
    var onFail: (() -> Void)?
    
    init(flowViewModel: TravelRequestFlowViewModel) {
        self.flowViewModel = flowViewModel
        self.rootView = TravelHowView(titleText: flowViewModel.moodSummary)
        self.viewModel = TravelHowViewModel(planId: flowViewModel.planId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindFlowViewModel()
        bindViewModel()
    }
    
    private func bindFlowViewModel() {
        if let transportTitle = flowViewModel.transportation.value {
            if let matchedButton = rootView.transportOptionView.transportButtons.first(where: {
                $0.title(for: .normal) == transportTitle
            }) {
                viewModel.selectedTransportRelay.accept(matchedButton)
            }
        }
        
        if let selectedCategoryTitles = flowViewModel.categories.value {
            let matchedButtons = rootView.categoryOptionView.categoryButtons.filter {
                guard let title = $0.title(for: .normal) else { return false }
                return selectedCategoryTitles.contains(title)
            }
            viewModel.selectedCategoriesRelay.accept(matchedButtons)
        }
    }
    
    private func bindViewModel() {
        //TODO: Map 구현 후 변경
        rootView.headerView.currentStep = 2 //3
        
        let transportTapStream = Observable.merge(rootView.transportOptionView.transportButtons.map { button in
            button.rx.tap.map { button }
        })
        
        let categoryTapStream = Observable.merge(rootView.categoryOptionView.categoryButtons.map { button in
            button.rx.tap.map { button }
        })
        
        let input = TravelHowViewModel.Input(
            transportTapped: transportTapStream,
            categoryTapped: categoryTapStream,
            prevButtonTapped: rootView.previousButton.rx.tap.asObservable(),
            doneButtonTapped: rootView.doneButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedTransport
            .drive(onNext: { [weak self] selected in
                guard let self = self else { return }
                self.rootView.transportOptionView.transportButtons.forEach {
                    $0.isSelected = ($0 == selected)
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedCategories
            .drive(onNext: { [weak self] selected in
                guard let self = self else { return }
                self.rootView.categoryOptionView.categoryButtons.forEach {
                    $0.updateTheme(selected.contains($0) ? .color : .transparent)
                }
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                guard let self else { return }
                let hostView = self.tabBarController?.view ?? self.view.window ?? self.view
                LoadingOverlayView.shared.show(in: hostView!)
                if isLoading {
                    LoadingOverlayView.shared.updateText("길동이가 열심히\n여행을 생성 중이에요\n(최대 1분 소요)")
                    LoadingOverlayView.shared.show(in: hostView!)
                    self.rootView.doneButton.isEnabled = false
                    self.view.isUserInteractionEnabled = false
                } else {
                    LoadingOverlayView.shared.hide()
                    self.rootView.doneButton.isEnabled = true
                    self.view.isUserInteractionEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .emit(onNext: { ToastManager.shared.show(message: $0) })
            .disposed(by: disposeBag)
        
        output.navigateToPrev
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.flowViewModel.transportation.accept(self.viewModel.transportation)
                self.flowViewModel.categories.accept(self.viewModel.categories)
                self.onPrev?()
            })
            .disposed(by: disposeBag)
        
        output.showGeneratedConfirmModal
            .emit(onNext: { [weak self] in
                self?.presentGeneratedModal()
            })
            .disposed(by: disposeBag)
        
        output.showGenerationFailed
            .emit(onNext: { [weak self] in
                guard let self else { return }
                let alert = UIAlertController(
                    title: "생성 실패",
                    message: "길동이가 여행 생성을 실패하였습니다.\n잠시 후 다시 시도해주세요.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.onFail?()
                }))
                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.flowViewModel.transportation.accept(self.viewModel.transportation)
                self.flowViewModel.categories.accept(self.viewModel.categories)
                
                if self.flowViewModel.isHowValid {
                    self.onComplete?(self.flowViewModel.planId)
                } else {
                    ToastManager.shared.show(message: "필수 정보를 입력하지 않았습니다.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func presentGeneratedModal() {
        let modal = CustomModalView(
            title: "길동이가 생성한 여행을\n확인하시겠습니까?",
            confirmTitle: "확인"
        )
        
        modal.onConfirm = { [weak self] in
            self?.viewModel.navigateToNextRelay.accept(())
        }
        
        modal.onCancel = { [weak self] in
            let mainHomeVC = MainHomeViewController()
            self?.navigationController?.setViewControllers([mainHomeVC], animated: true)
        }
        
        view.addSubview(modal)
        modal.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

