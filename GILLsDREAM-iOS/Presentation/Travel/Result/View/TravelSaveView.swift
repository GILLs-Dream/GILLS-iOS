//
//  TravelSaveView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/11/25.
//

import UIKit
import SnapKit
import Then

final class TravelSaveView: UIView {
    
    // MARK: Property
    var nextButtonBottomConstraint: Constraint?

    // MARK: Views
    private let titleLabel = UILabel()
    let travelImageView = UIImageView()
    let travelImageSelectButton = UIButton()
    lazy var travelNameTextField = UITextField()
    let lengthLabel = UILabel()
    lazy var saveButton = CustomButton(title: "저장 완료")
    
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
            travelImageView,
            travelImageSelectButton,
            travelNameTextField,
            lengthLabel,
            saveButton
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.attributedText = "해당 여행의 사진과 이름을\n정해주세요".pretendardAttributedString(style: .subtitle2)
        }
        
        travelImageView.do {
            $0.image = .imgDefaultProfile
            $0.layer.cornerRadius = 80
        }
        
        travelImageSelectButton.do {
            $0.setImage(.imgCamera, for: .normal)
            $0.layer.cornerRadius = 25
        }
        
        travelNameTextField.do {
            $0.attributedPlaceholder = "여행 이름 입력".pretendardAttributedString(style: .body1, color: .gray)
            $0.font = .PretendardStyle.body1.font
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8
            $0.returnKeyType = .done
            $0.addLeftPadding()
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
        
        travelImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(41)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(160)
        }
        
        travelImageSelectButton.snp.makeConstraints {
            $0.bottom.equalTo(travelImageView)
            $0.trailing.equalTo(travelImageView).offset(15)
            $0.size.equalTo(50)
        }
        
        travelNameTextField.snp.makeConstraints {
            $0.top.equalTo(travelImageSelectButton.snp.bottom).offset(37)
            $0.horizontalEdges.equalToSuperview().inset(23)
            $0.height.equalTo(52)
        }
        
        lengthLabel.snp.makeConstraints {
            $0.top.equalTo(travelNameTextField.snp.bottom).offset(10)
            $0.trailing.equalTo(travelNameTextField)
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            self.nextButtonBottomConstraint = $0.bottom.equalToSuperview().inset(50).constraint
        }
    }
}

extension TravelSaveView {
    // 프로필 이미지 교체
    func updateProfileImage(_ image: UIImage) {
        travelImageView.image = image
        travelImageView.contentMode = .scaleAspectFill
        travelImageView.makeCircular()
    }
    
    // 버튼 교체
    func updateNextButtonTheme(isAvailable: Bool) {
        saveButton.updateTheme(isAvailable ? .color : .transparent)
        saveButton.isEnabled = isAvailable
    }
    
    // 버튼 위치 업데이트
    func updateNextButtonBottom(by offset: CGFloat) {
        nextButtonBottomConstraint?.update(inset: offset)
    }
}
