//
//  TravelRequestViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/15/25.
//

import UIKit
import RxSwift
import RxCocoa

enum TravelRequestStep {
    case region
    case mood
    case video
}

final class TravelRequestViewController: BaseViewController {
    private let rootView = TravelRequestView()
    private let viewModel = TravelRequestViewModel()
    private let flowViewModel: TravelRequestFlowViewModel
    private let disposeBag = DisposeBag()
    private var storedMood: PlanMood?
    var onNext: (() -> Void)?
    
    override func loadView() {
        self.view = rootView
    }
    
    init(flowViewModel: TravelRequestFlowViewModel) {
        self.flowViewModel = flowViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapToDismissAllInputs()
        setUpDelegate()
        bindViewModel()
    }
    
    override func shouldDismissWhenTapped(on view: UIView?) -> Bool {
        if view?.isDescendant(of: rootView.sendButton) == true {
            return false
        }
        return true
    }
    
    private func setUpDelegate() {
        rootView.requestTextView.delegate = self
    }
    
    private func bindViewModel() {
        let input = TravelRequestViewModel.Input(
            textInput: rootView.requestTextView.rx.text.orEmpty.asObservable(),
            sendButtonTapped: rootView.sendButton.rx.tap
                .do(onNext: { [weak self] in self?.view.endEditing(true) })
                .delay(.milliseconds(100), scheduler: MainScheduler.instance)
                .asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                guard let self else { return }
                let hostView = self.tabBarController?.view ?? self.view.window ?? self.view
                if isLoading {
                    LoadingOverlayView.shared.updateText("길동이가 열심히\n여행을 생성 중이에요\n(최대 1분 소요)")
                    LoadingOverlayView.shared.show(in: hostView!)
                    self.rootView.sendButton.isEnabled = false
                    self.view.isUserInteractionEnabled = false
                } else {
                    LoadingOverlayView.shared.hide()
                    self.rootView.sendButton.isEnabled = true
                    self.view.isUserInteractionEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        output.showInvalidRegionModal
            .emit(onNext: { [weak self] in
                guard let self else { return }
                let modal = CustomModalView(
                    title: "올바르지 않은 지역입니다.\n국내지역을 다시 입력해 주세요.",
                    confirmTitle: "확인"
                )
                modal.onConfirm = { [weak modal] in modal?.removeFromSuperview() }
                let host = self.tabBarController?.view ?? self.view!
                modal.frame = host.bounds
                modal.alpha = 0
                host.addSubview(modal)
                UIView.animate(withDuration: 0.2) { modal.alpha = 1 }
            })
            .disposed(by: disposeBag)
        
        output.isSendEnabled
            .drive(rootView.sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.moodResult
            .emit(onNext: { [weak self] mood in
                guard let self else { return }
                self.flowViewModel.planId = mood.id.value
                self.flowViewModel.moodSummary = mood.moodSummary
            })
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .drive(onNext: { [weak self] in
                self?.onNext?()
            })
            .disposed(by: disposeBag)
        
        Driver.combineLatest(output.currentStep, output.latestRegionText)
            .drive(onNext: { [weak self] step, region in
                guard let self else { return }
                switch step {
                case .region:
                    self.rootView.update(for: .region)
                case .mood:
                    self.rootView.requestTextView.text = ""
                    self.rootView.requestPlaceHolder.isHidden = false
                    self.rootView.update(for: .mood, with: region)
                case .video:
                    self.rootView.requestTextView.text = ""
                    self.rootView.requestPlaceHolder.isHidden = false
                    self.rootView.update(for: .video)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension TravelRequestViewController: UITextViewDelegate {
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        rootView.requestPlaceHolder.isHidden = !(textView.text?.isEmpty ?? true)
        scrollToCaret(in: textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        scrollToCaret(in: textView)
    }

    private func scrollToCaret(in textView: UITextView) {
        guard let range = textView.selectedTextRange else { return }
        // 커서 rect을 약간 키워서 완전히 보이게
        var rect = textView.caretRect(for: range.end)
        rect = rect.insetBy(dx: 0, dy: -6)
        textView.scrollRectToVisible(rect, animated: false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        rootView.requestPlaceHolder.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        rootView.requestPlaceHolder.isHidden = !(textView.text?.isEmpty ?? true) ? true : false
    }
}
