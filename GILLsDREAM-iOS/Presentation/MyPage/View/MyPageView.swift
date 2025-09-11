//
//  MyPageView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import UIKit
import SnapKit
import Kingfisher

final class MyPageView: UIView {
    
    // MARK: Properties
    //FIX: 임시
    private var userNickname: String = "SAM"
    private var userEmail: String = "gildong@gill.com"
    
    // MARK: Views
    private let titleLabel = UILabel()
    let profileImageView = UIImageView()
    let nicknameLabel = UILabel()
    let emailLabel = UILabel()
    private let divideLine = UIView()
    private let buttonStackView = UIStackView()
    let serviceButton = UIButton()
    let withdrawButton = UIButton()
    let logoutButton = UIButton()
    
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
            profileImageView,
            nicknameLabel,
            emailLabel,
            divideLine,
            buttonStackView
        ].forEach { self.addSubview($0) }
        
        [
            serviceButton,
            withdrawButton,
            logoutButton
        ].forEach { buttonStackView.addArrangedSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "마이페이지".pretendardAttributedString(style: .body0)
        }
        
        profileImageView.do {
            $0.image = .imgDefaultProfile
            $0.layer.cornerRadius = 38
            $0.clipsToBounds = true
        }
        
        divideLine.do {
            $0.backgroundColor = .white
        }
        
        buttonStackView.do {
            $0.axis = .vertical
            $0.spacing = 5
            $0.alignment = .leading
        }
        
        serviceButton.do {
            $0.setAttributedTitle("서비스 이용약관".pretendardAttributedString(style: .body1), for: .normal)
        }
        
        withdrawButton.do {
            $0.setAttributedTitle("회원탈퇴".pretendardAttributedString(style: .body1), for: .normal)
        }
        
        logoutButton.do {
            $0.setAttributedTitle("로그아웃".pretendardAttributedString(style: .body1), for: .normal)
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.centerX.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(78)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(15)
            $0.centerY.equalTo(profileImageView).offset(-10)
        }
        
        emailLabel.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel)
            $0.top.equalTo(nicknameLabel.snp.bottom)
        }
        
        divideLine.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(26)
            $0.horizontalEdges.equalToSuperview().inset(17)
            $0.height.equalTo(0.7)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(divideLine.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
    }
}

extension MyPageView {
    func apply(profileImg: String) {
        guard let url = URL(string: profileImg), !profileImg.isEmpty else {
            profileImageView.image = .imgDefaultProfile
            return
        }
        
        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = self.profileImageView.bounds.height / 2
            $0.kf.setImage(
                with: url,
                placeholder: UIImage(named: "icAccount"),
                options: [.transition(.fade(0.2))]
            )
        }
    }
    
    func apply(nickname: String) {
        nicknameLabel.attributedText = "\(nickname)님"
            .pretendardAttributedString(style: .subtitle2)
    }
    
    func apply(email: String) {
        emailLabel.attributedText = email.pretendardAttributedString(style: .body2)
    }
}
