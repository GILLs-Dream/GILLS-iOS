//
//  TosView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/10/25.
//

import UIKit
import SnapKit
import Then

final class TosView: UIView {
    
    // MARK: Views
    private let titleLabel = UILabel()
    private let agreementStackView = UIStackView()
    let allAgreeAgreementView = TosAgreementView(title: "전체 동의", type: .All)
    let serviceAgreementView = TosAgreementView(title: "(필수) 서비스 이용약관", type: .Other)
    let personalAgreementView = TosAgreementView(title: "(필수) 개인정보 수집/이용 동의", type: .Other)
    let marketingAgreementView = TosAgreementView(title: "(선택) 마케팅 정보 수신 동의", type: .Other)
    
    lazy var nextButton = CustomButton(enable: false)
    
    
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
            agreementStackView,
            nextButton
        ].forEach { self.addSubview($0) }
        
        [
            allAgreeAgreementView,
            serviceAgreementView,
            personalAgreementView,
            marketingAgreementView
        ].forEach {
            agreementStackView.addArrangedSubview($0)
        }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.textAlignment = .left
            $0.attributedText = "서비스 이용약관에 동의해주세요.".pretendardAttributedString(style: .subtitle2)
        }
        
        agreementStackView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .vertical
            $0.spacing = 0
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            $0.leading.equalToSuperview().offset(24)
        }
        
        agreementStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(31)
            $0.horizontalEdges.equalToSuperview().inset(19)
            $0.height.equalTo(200)
        }
        
        allAgreeAgreementView.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalToSuperview()
        }
        
        serviceAgreementView.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalToSuperview()
        }
        
        personalAgreementView.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalToSuperview()
        }
        
        marketingAgreementView.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
}

extension TosView {
    // 버튼 교체
    func updateNextButtonTheme(isAvailable: Bool) {
        nextButton.updateTheme(isAvailable ? .color : .transparent)
        nextButton.updateTitle(isAvailable ? "가입 완료" : "다음")
        nextButton.isEnabled = isAvailable
    }
}
