//
//  TravelRequestView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import UIKit
import Lottie

final class TravelRequestView: UIView {
    // MARK: Views
    private let titleLabel = UILabel()
    private let exampleLabel = UILabel()
    private let extraLabel = UILabel()
    private let underlineView = UIView()
    let requestTextView = UITextView()
    let requestPlaceHolder = UILabel()
    let sendButton = UIButton()
    let loadingView = UIView()
    let loadingLottieView = LottieAnimationView(name: "gill's dream")
    let loadingLabel = UILabel()
    
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
            extraLabel,
            underlineView,
            requestTextView,
            requestPlaceHolder,
            sendButton,
            loadingView
        ].forEach { self.addSubview($0) }
        
        requestTextView.addSubview(requestPlaceHolder)
        
        [
            loadingLottieView,
            loadingLabel
        ].forEach { loadingView.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "예시".pretendardAttributedString(style: .title1)
        }
        
        exampleLabel.do {
            $0.textAlignment = .left
            $0.numberOfLines = 3
            let baseText = "가을 제주도에서 찐친들과\n인스타그래머블하고 고즈넉한\n여행을 즐기고 싶어"
            $0.attributedText = baseText.pretendardAttributedString(style: .title4, color: .white)
            $0.applyMultipleAttributes(styles: [
                (target: "가을 제주도에서 찐친들", font: .PretendardStyle.title4.font, color: .mainYellow),
                (target: "인스타그래머블", font: .PretendardStyle.title4.font, color: .mainYellow),
                (target: "핫한", font: .PretendardStyle.title4.font, color: .mainYellow)
            ])
        }
        
        extraLabel.do {
            $0.attributedText = "분위기가 구체적일수록 좋아요!".pretendardAttributedString(style: .body3)
        }
        
        underlineView.do {
            $0.backgroundColor = .white
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
            $0.attributedText = "지금 어떤 분위기의 여행이 가고싶나요?".pretendardAttributedString(style: .subtitle5, color: .white)
            $0.backgroundColor = .clear
        }
        
        sendButton.do {
            $0.setImage(.imgArrowRight, for: .normal)
        }
        
        loadingView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            $0.isHidden = true
        }
        
        loadingLottieView.do {
            $0.loopMode = .loop
            $0.animationSpeed = 4
            $0.contentMode = .scaleAspectFill
        }
        
        loadingLabel.do {
            $0.numberOfLines = 2
            $0.attributedText = "길동이가 열심히\n여행을 생성 중이에요".pretendardAttributedString(style: .subtitle1, color: .white)
            $0.textAlignment = .center
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            $0.leading.equalToSuperview().offset(24)
        }
        
        exampleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(titleLabel)
        }
        
        extraLabel.snp.makeConstraints {
            $0.top.equalTo(exampleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(titleLabel)
        }
        
        underlineView.snp.makeConstraints {
            $0.top.equalTo(extraLabel.snp.bottom)
            $0.horizontalEdges.equalTo(extraLabel)
            $0.height.equalTo(1)
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
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loadingLottieView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loadingLabel.snp.makeConstraints {
            $0.top.equalTo(loadingLottieView.snp.bottom).offset(-50)
            $0.centerX.equalToSuperview()
        }
    }
}
