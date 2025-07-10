//
//  ProfileView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/9/25.
//

import UIKit
import SnapKit
import Then

final class ProfileView: UIView {
    
    // MARK: Property
    var nextButtonBottomConstraint: Constraint?

    // MARK: Views
    private let titleLabel = UILabel()
    private let profileView = UIImageView()
    private let profileSelectButton = UIButton()
    lazy var nicknameTextField = UITextField()
    let duplicateCheckButton = UIButton()
    let errorLabel = UILabel()
    let completeLabel = UILabel()
    let lengthLabel = UILabel()
    lazy var nextButton = CustomButton(enable: false)
    lazy var ableNextButton = CustomButton(theme: .color)
    
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpFoundation()
        setUpHierarchy()
        setUpUI()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setUpFoundation
    private func setUpFoundation() {
        self.backgroundColor = .clear
    }
    
    // MARK: setUpHierarchy
    private func setUpHierarchy() {
        [
            titleLabel,
            profileView,
            profileSelectButton,
            nicknameTextField,
            duplicateCheckButton,
            errorLabel,
            completeLabel,
            lengthLabel,
            nextButton,
            ableNextButton
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.attributedText = "길동이의 꿈을 함께 할\n사진과 별명을 추가해주세요".pretendardAttributedString(style: .subtitle2)
        }
        
        profileView.do {
            $0.image = .imgDefaultProfile
            $0.layer.cornerRadius = 80
        }
        
        profileSelectButton.do {
            $0.setImage(.imgCamera, for: .normal)
            $0.layer.cornerRadius = 25
        }
        
        nicknameTextField.do {
            $0.attributedPlaceholder = "별명 입력".pretendardAttributedString(style: .body1, color: .gray)
            $0.font = .PretendardStyle.body1.font
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8
            $0.returnKeyType = .done
            $0.addLeftPadding()
        }
        
        duplicateCheckButton.do {
            $0.backgroundColor = .mainBlue
            $0.setAttributedTitle("중복 확인".pretendardAttributedString(style: .body1, color: .white), for: .normal)
            $0.layer.cornerRadius = 3
        }
        
        errorLabel.do {
            $0.attributedText = "이미 존재하는 별명입니다".pretendardAttributedString(style: .body2, color: .mainRed)
            $0.isHidden = true
        }
        
        completeLabel.do {
            $0.attributedText = "사용 가능한 별명입니다.".pretendardAttributedString(style: .body2, color: .white)
            $0.isHidden = true
        }
        
        lengthLabel.do {
            $0.attributedText = "0/10".pretendardAttributedString(style: .body2)
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            $0.leading.equalToSuperview().offset(24)
        }
        
        profileView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(41)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(160)
        }
        
        profileSelectButton.snp.makeConstraints {
            $0.bottom.equalTo(profileView)
            $0.trailing.equalTo(profileView).offset(15)
            $0.size.equalTo(50)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(profileSelectButton.snp.bottom).offset(37)
            $0.horizontalEdges.equalToSuperview().inset(23)
            $0.height.equalTo(52)
        }
        
        duplicateCheckButton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameTextField)
            $0.trailing.equalTo(nicknameTextField).inset(12)
            $0.verticalEdges.equalTo(nicknameTextField).inset(11)
            $0.width.equalTo(74)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            $0.leading.equalTo(nicknameTextField)
        }
        
        completeLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            $0.leading.equalTo(nicknameTextField)
        }
        
        lengthLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            $0.trailing.equalTo(nicknameTextField)
        }
        
        nextButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            self.nextButtonBottomConstraint = $0.bottom.equalToSuperview().inset(50).constraint
        }
    }
}

extension ProfileView {
    // 버튼 교체
    func updateNextButtonTheme(isAvailable: Bool) {
        nextButton.updateTheme(isAvailable ? .color : .transparent)
        nextButton.isEnabled = isAvailable
    }
    
    // 버튼 위치 업데이트
    func updateNextButtonBottom(by offset: CGFloat) {
        nextButtonBottomConstraint?.update(inset: offset)
    }
}
