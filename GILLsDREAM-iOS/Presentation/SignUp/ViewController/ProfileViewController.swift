//
//  ProfileViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/9/25.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let rootView = ProfileView()
    private let viewModel = ProfileViewModel()
    private let nicknameMaxLength = 10
    private var isEnable: Bool = true
    
    
    // MARK: Life Cycle
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .mainBlue
        configureCustomNavigationBar()
        bindViewModel()
        setUpDelegate()
        observeKeyboardNotifications()
    }
    
    private func setUpDelegate() {
        rootView.nicknameTextField.delegate = self
    }
    
    //MARK: View Model
    private func bindViewModel() {
        let input = ProfileViewModel.Input(
            nicknameInput: rootView.nicknameTextField.rx.text.orEmpty.asObservable(),
            duplicateCheckTapped: rootView.duplicateCheckButton.rx.tap.asObservable(),
            nextButtonTapped: rootView.nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.nicknameCountText
            .drive(rootView.lengthLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.duplicateResult
            .drive(onNext: { [weak self] isAvailable in
                guard let self = self else { return }
                self.rootView.errorLabel.isHidden = isAvailable
                self.rootView.completeLabel.isHidden = !isAvailable
                self.rootView.updateNextButtonTheme(isAvailable: isAvailable)
            })
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let tosVC = TosViewController()
                self.navigationController?.pushViewController(tosVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
            rootView.updateNextButtonBottom(by: keyboardHeight + 50)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        rootView.updateNextButtonBottom(by: 50)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rootView.endEditing(true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > nicknameMaxLength {
            textField.text = String(text.prefix(nicknameMaxLength))
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true } // backspace 허용
        if string.isComposing { return true } // 조합 중인 입력 허용
        return true
    }
}
