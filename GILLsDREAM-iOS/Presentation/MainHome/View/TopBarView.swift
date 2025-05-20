//
//  TopBarView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/17/25.
//

import UIKit
import SnapKit
import Then

final class TopBarView: UIView {
    
    // MARK: Views
    private let welcomeLabel = UILabel()
    private let alarmButton = UIButton()
    private let alarmView = UIView()
    private let alarmLabel = UILabel()
    private let accountButton = UIButton()
    
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
            welcomeLabel,
            accountButton,
            alarmButton,
            alarmView,
            alarmLabel,
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        welcomeLabel.do {
            $0.attributedText = "안녕하세요, SAM님!".pretendardAttributedString(style: .body1)
        }
        
        alarmButton.do {
            $0.setImage(.icAlarm, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
        }
        
        alarmView.do {
            $0.backgroundColor = .mainRed
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 6.5
        }
        
        alarmLabel.do {
            $0.attributedText = "3".pretendardAttributedString(style: .smalltext)
        }
        
        accountButton.do {
            $0.setImage(.icAccount, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        welcomeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        accountButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(22)
        }
        
        alarmButton.snp.makeConstraints {
            $0.centerY.equalTo(accountButton)
            $0.trailing.equalTo(accountButton.snp.leading).offset(-15)
            $0.size.equalTo(22)
        }
        
        alarmView.snp.makeConstraints {
            $0.trailing.equalTo(alarmButton).inset(-3)
            $0.bottom.equalTo(alarmButton).inset(-3)
            $0.size.equalTo(13)
        }
        
        alarmLabel.snp.makeConstraints {
            $0.center.equalTo(alarmView)
        }
    }
}
