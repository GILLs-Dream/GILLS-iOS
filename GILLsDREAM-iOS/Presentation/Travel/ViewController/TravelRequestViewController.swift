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
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavigationBar()
        setUpDelegate()
        setupTapToDismissKeyboard()
        bindViewModel()
    }
    
    private func setUpDelegate() {
        rootView.requestTextView.delegate = self
    }
    
    private func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showLoading(_ show: Bool) {
        if show {
            rootView.loadingView.isHidden = false
            rootView.loadingLottieView.play()
            
            UIView.animate(withDuration: 0.3) {
                self.rootView.loadingView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.rootView.loadingView.alpha = 0
            }) { _ in
                self.rootView.loadingView.isHidden = true
                self.rootView.loadingLottieView.stop()
            }
        }
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
                self.view.endEditing(true)      // 키보드 내리기
                self.showLoading(true)          // 로딩 시작
            })
            .delay(.milliseconds(3000), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.showLoading(false)          // 로딩 종료
                let nextVC = TravelRequestViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
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

extension TravelRequestViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // sendButton 눌렀을 때는 키보드 내리는 제스처 무시
        if touch.view?.isDescendant(of: rootView.sendButton) == true {
            return false
        }
        return true
    }
}
