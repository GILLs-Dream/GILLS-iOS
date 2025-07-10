//
//  InitialView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 6/3/25.
//

import UIKit
import SnapKit

final class InitialView: UIView {
    
    // MARK: Views
    private let backgroundView = UIImageView()
    private let loginStackView = UIStackView()
    private let loginLabel = UILabel()
    let kakaoButton = UIButton()
    let appleButton = UIButton()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpHierarchy()
        setUpUI()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setUpHierarchy
    private func setUpHierarchy() {
        [
            backgroundView,
            loginStackView
        ].forEach { self.addSubview($0) }
        
        [
            loginLabel,
            kakaoButton,
            appleButton
        ].forEach { loginStackView.addArrangedSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        backgroundView.do {
            $0.image = .imgInit
            $0.contentMode = .scaleAspectFit
        }
        
        loginStackView.do {
            $0.axis = .vertical
            $0.spacing = 7
            $0.alignment = .center
        }
        
        loginLabel.do {
            $0.attributedText = "SNS 계정으로 빠르게 시작하기".pretendardAttributedString(style: .body2)
        }
        
        kakaoButton.do {
            $0.setButtonStyle(title: "카카오로 로그인",
                              titleColor: .black,
                              backgroundColor: .kakaoYellow)
        }
        
        appleButton.do {
            $0.setButtonStyle(title: "애플로 로그인",
                              titleColor: .white,
                              backgroundColor: .black)
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loginStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(340)
        }
        
        appleButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(340)
        }
    }
}
