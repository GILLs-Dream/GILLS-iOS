//
//  SignUpCompleteView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import UIKit

final class SignUpCompleteView: UIView {
    // MARK: Views
    private let gillImageView = UIImageView()
    private let completeLabel = UILabel()
    lazy var completeButton = CustomButton(theme: .color, title: "시작하기")
    
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
            gillImageView,
            completeLabel,
            completeButton
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        gillImageView.do {
            $0.image = .imgGill
            $0.contentMode = .scaleAspectFill
        }
        
        completeLabel.do {
            $0.numberOfLines = 2
            $0.attributedText = "가입이 완료되었습니다.\n길동이와 좋은 꿈 되세요".pretendardAttributedString(style: .subtitle1)
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        gillImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(211)
            $0.width.equalTo(198)
        }
        
        completeLabel.snp.makeConstraints {
            $0.top.equalTo(gillImageView.snp.bottom).offset(47)
            $0.centerX.equalToSuperview()
        }
        
        completeButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
}
