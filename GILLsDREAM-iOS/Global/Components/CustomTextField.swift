//
//  CustomTextField.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import UIKit

enum VerificationButtonType {
    case checkDuplicate // 중복확인
    case sendCode       // 인증코드
    case confirm        // 확인
    case resend         // 재전송
}

final class CustomTextField: UIView {
    let textField = UITextField()
    let actionButton = UIButton()
    let resultLabel = UILabel()
    let timerLabel = UILabel()
    
    var buttonType: VerificationButtonType = .confirm {
        didSet { updateButtonTitle() }
    }

    var timeLimit: TimeInterval = 300 // 5분
    
    private var timer: Timer?
    private var remainingTime: TimeInterval = 0

    var onButtonTapped: (() -> Void)?

    init(type: VerificationButtonType) {
        super.init(frame: .zero)
        self.buttonType = type
        setUpHierachy()
        setUpUI()
        setUpLayout()
        updateButtonTitle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpHierachy() {
        [
            textField,
            actionButton,
            timerLabel
        ].forEach { self.addSubview($0) }
    }

    private func setUpUI() {
        textField.do {
            $0.font = .PretendardStyle.body1.font
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8
            $0.returnKeyType = .done
            $0.addLeftPadding()
        }

        actionButton.do {
            $0.layer.cornerRadius = 3
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = .mainBlue
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }

        timerLabel.do {
            $0.font = .PretendardStyle.body2.font
            $0.textColor = .white
            $0.isHidden = true
        }
    }

    private func setUpLayout() {
        textField.snp.makeConstraints {
            $0.height.equalTo(52)
            $0.top.leading.trailing.equalToSuperview()
        }

//        actionButton.snp.makeConstraints {
//            $0.centerY.equalTo(textField)
//            $0.trailing.equalTo(textField).inset(12)
//            $0.verticalEdges.equalTo(textField).inset(11)
//            $0.width.equalTo(74)
//        }

        timerLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(8)
            $0.leading.equalTo(textField)
        }
    }

    private func updateButtonTitle() {
        let title: String
        switch buttonType {
        case .sendCode: title = "인증코드"
        case .confirm: title = "확인"
        case .resend: title = "재전송"
        case .checkDuplicate: title = "중복확인"
        }
        actionButton.setAttributedTitle(title.pretendardAttributedString(style: .body1, color: .white), for: .normal)
    }

    @objc private func buttonTapped() {
        onButtonTapped?()
    }

    private func tick() {
        remainingTime -= 1
        updateTimerLabel()

        if remainingTime <= 0 {
            timer?.invalidate()
            timer = nil
            timerLabel.text = "00:00"
            buttonType = .resend
        }
    }

    private func updateTimerLabel() {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        timerLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
}

extension CustomTextField {
    // MARK: Timer
    func startTimer() {
        remainingTime = timeLimit
        timerLabel.isHidden = false
        updateTimerLabel()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerLabel.isHidden = true
    }
}
