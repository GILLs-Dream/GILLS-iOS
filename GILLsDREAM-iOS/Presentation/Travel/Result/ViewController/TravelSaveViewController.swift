//
//  TravelSaveViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/11/25.
//

import UIKit
import RxSwift
import RxCocoa

class TravelSaveViewController: UIViewController {
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let rootView = TravelSaveView()
    private let viewModel: TravelSaveViewModel
    private let travelnameMaxLength = 10
    private var isEnable: Bool = true
    var onComplete: (() -> Void)?

    init(planId: Int) {
        self.viewModel = TravelSaveViewModel(planId: planId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .mainBlue
        tabBarController?.isTabBarHidden = true
        bindViewModel()
        setUpDelegate()
        observeKeyboardNotifications()
    }
    
    private func setUpDelegate() {
        rootView.travelNameTextField.delegate = self
    }
    
    //MARK: View Model
    private func bindViewModel() {
        let input = TravelSaveViewModel.Input(
            profileImageButtonTapped: rootView.travelImageSelectButton.rx.tap.asObservable(),
            travelNameInput: rootView.travelNameTextField.rx.text.orEmpty.asObservable(),
            saveButtonTapped: rootView.saveButton.rx.tap
                .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
                .asObservable()
        )

        let output = viewModel.transform(input: input)

        output.selectedImage
            .drive(onNext: { [weak self] image in
                guard let self = self else { return }
                self.rootView.updateProfileImage(image)
            })
            .disposed(by: disposeBag)
        
        output.travelNameCountText
            .drive(rootView.lengthLabel.rx.text)
            .disposed(by: disposeBag)

        output.isNextEnabled
            .drive(onNext: { [weak self] enabled in
                self?.rootView.saveButton.isEnabled = enabled
                self?.rootView.updateNextButtonTheme(isAvailable: enabled)
            })
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.onComplete?()
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .emit(onNext: { message in
                ToastManager.shared.show(message: message)
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

extension TravelSaveViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rootView.endEditing(true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > travelnameMaxLength {
            textField.text = String(text.prefix(travelnameMaxLength))
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true } // backspace 허용
        if string.isComposing { return true } // 조합 중인 입력 허용
        return true
    }
}
