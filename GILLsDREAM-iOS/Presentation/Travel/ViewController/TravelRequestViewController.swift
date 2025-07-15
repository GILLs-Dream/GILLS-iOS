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
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func bindViewModel() {
        let input = TravelRequestViewModel.Input(
            textInput: rootView.requestTextView.rx.text.orEmpty.asObservable(),
            sendButtonTapped: rootView.sendButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isSendEnabled
            .drive(rootView.sendButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
//                let nextVC = TravelCreateViewController()
//                self.navigationController?.pushViewController(nextVC, animated: true)
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
