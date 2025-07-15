//
//  TravelRequestView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import UIKit

final class TravelRequestView: UIView {
    // MARK: Views
    private let titleLabel = UILabel()
    private let exampleLabel = UILabel()
    private let maxLengthLabel = UILabel()
    let requestTextView = UITextView()
    let requestPlaceHolder = UILabel()
    let sendButton = UIButton()
    
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
            exampleLabel,
            maxLengthLabel,
            requestTextView,
            sendButton
        ].forEach { self.addSubview($0) }
        
        requestTextView.addSubview(requestPlaceHolder)
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "예시".pretendardAttributedString(style: .title1)
        }
        
        exampleLabel.do {
            $0.textAlignment = .left
            $0.numberOfLines = 3
            $0.attributedText = "가을에 찐친 3명과\n핫한 분위기의 여행을\n제주도 지역에서 즐기고 싶어".pretendardAttributedString(style: .title4, color: .gray)
        }
        
        maxLengthLabel.do {
            $0.attributedText = "최대 80자".pretendardAttributedString(style: .body3, color: .gray)
        }
        
        requestTextView.do {
            $0.backgroundColor = .clear
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 30
            $0.layer.borderWidth = 5
            $0.layer.borderColor = UIColor.white.cgColor
            $0.font = .PretendardStyle.subtitle5.font
            $0.textColor = .white
            $0.textContainerInset = .init(top: 15, left: 17, bottom: 15, right: 53)
            $0.isScrollEnabled = false
        }
        
        requestPlaceHolder.do {
            $0.attributedText = "지금 어떤 여행이 가고싶나요?".pretendardAttributedString(style: .subtitle5, color: .white)
            $0.backgroundColor = .clear
        }
        
        sendButton.do {
            $0.setImage(.imgArrowRight, for: .normal)
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            $0.leading.equalToSuperview().offset(24)
        }
        
        exampleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(titleLabel)
        }
        
        requestTextView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(21)
            $0.bottom.equalTo(self.keyboardLayoutGuide.snp.top).offset(-100)
            $0.height.greaterThanOrEqualTo(60)
        }
        
        requestPlaceHolder.snp.makeConstraints {
            $0.centerY.equalTo(requestTextView)
            $0.leading.equalTo(requestTextView).inset(17)
        }
        
        sendButton.snp.makeConstraints {
            $0.centerY.equalTo(requestTextView)
            $0.trailing.equalTo(requestTextView).inset(17)
            $0.height.equalTo(20)
            $0.width.equalTo(28)
        }
    }
}
