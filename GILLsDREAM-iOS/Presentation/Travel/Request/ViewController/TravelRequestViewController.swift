//
//  TravelRequestViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelRequestViewController: BaseViewController {
    
    private let rootView = TravelRequestView()
    private let viewModel = TravelRequestViewModel()
    private let disposeBag = DisposeBag()
    var onNext: (() -> Void)?
    
    override func loadView() {
        self.view = rootView
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
                .do(onNext: { [weak self] in
                    self?.view.endEditing(true)
                })
                .delay(.milliseconds(100), scheduler: MainScheduler.instance)
                .asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isSendEnabled
            .drive(rootView.sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.view.endEditing(true) // 키보드 내리기
                self.rootView.lottieView.startAnimating()
            })
            .delay(.milliseconds(3000), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.rootView.lottieView.stopAnimating()
                self.onNext?()
            })
            .disposed(by: disposeBag)
    }
}

extension TravelRequestViewController: UITextViewDelegate {
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = rootView.requestTextView.sizeThatFits(size)
        
        rootView.requestPlaceHolder.isHidden = !textView.text.isEmpty
        rootView.requestTextView.constraints.forEach { (constraint) in
            if estimatedSize.height <= 60 { }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
}
