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
    let welcomeLabel = UILabel()
    private let alarmButton = UIButton()
    private let alarmView = UIView()
    private let alarmLabel = UILabel()
    let homeButton = HitTestButton()
    
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
            homeButton,
            alarmButton,
            alarmView,
            alarmLabel,
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
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
        
        homeButton.do {
            $0.setImage(.icHome, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
            (homeButton as? HitTestButton)?.hitTestInset = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -12)
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        welcomeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        homeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(3)
            $0.trailing.equalToSuperview().inset(25)
            $0.size.equalTo(55)
        }
//        
//        alarmButton.snp.makeConstraints {
//            $0.centerY.equalTo(accountButton)
//            $0.trailing.equalTo(accountButton.snp.leading).offset(-15)
//            $0.size.equalTo(22)
//        }
//        
//        alarmView.snp.makeConstraints {
//            $0.trailing.equalTo(alarmButton).inset(-3)
//            $0.bottom.equalTo(alarmButton).inset(-3)
//            $0.size.equalTo(13)
//        }
//        
//        alarmLabel.snp.makeConstraints {
//            $0.center.equalTo(alarmView)
//        }
    }
}

extension TopBarView {
    func apply(nickname: String) {
        welcomeLabel.attributedText = "안녕하세요, \(nickname)님!"
            .pretendardAttributedString(style: .body1)
    }
}

final class HitTestButton: UIButton {
    var hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10) // +20 확장
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let larger = bounds.inset(by: hitTestInset)
        return larger.contains(point)
    }
}
