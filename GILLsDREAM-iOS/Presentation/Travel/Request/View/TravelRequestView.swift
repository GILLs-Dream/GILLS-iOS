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
    let skipButton = UIButton()
    let lottieView = CustomLottieView(text: "길동이가 열심히\n여행을 생성 중이에요")
    
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
            skipButton,
            lottieView
        ].forEach { self.addSubview($0) }
        
        requestTextView.addSubview(requestPlaceHolder)
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "입력 예시".pretendardAttributedString(style: .title1)
        }
        
        exampleLabel.do {
            $0.textAlignment = .left
            $0.numberOfLines = 3
        }
        
        extraLabel.do {
            $0.numberOfLines = 2
        }
        
        underlineView.do {
            $0.backgroundColor = .white
        }
        
        requestTextView.do {
            $0.backgroundColor = .clear
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 30
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.white.cgColor
            $0.font = .PretendardStyle.subtitle6.font
            $0.textColor = .white
            $0.textContainerInset = .init(top: 17, left: 17, bottom: 15, right: 53)
            $0.isScrollEnabled = true
        }
        
        requestPlaceHolder.do {
            $0.backgroundColor = .clear
        }
        
        sendButton.do {
            $0.setImage(.imgArrowRight, for: .normal)
        }
        
        skipButton.do {
            $0.setAttributedTitle("건너뛰기".pretendardAttributedString(style: .body0), for: .normal)
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            $0.layer.cornerRadius = 30
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            $0.contentEdgeInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)
            $0.isHidden = true
        }
        
        lottieView.do {
            $0.isHidden = true
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
            $0.bottom.equalTo(skipButton.snp.top).offset(-12)
            $0.height.equalTo(60)
        }

        skipButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(21)
            $0.height.equalTo(60)
            $0.bottom.equalTo(self.keyboardLayoutGuide.snp.top).offset(-60)
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
        
        lottieView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TravelRequestView {
    func update(for step: TravelRequestStep, with location: String? = nil) {
        switch step {
        case .region:
            exampleLabel.attributedText = "제주".pretendardAttributedString(style: .title4, color: .mainYellow)
            extraLabel.isHidden = false
            extraLabel.attributedText = "*국내 지역을 입력해주세요.".pretendardAttributedString(style: .body2)
            underlineView.isHidden = true
            skipButton.isHidden = true
            requestPlaceHolder.attributedText = "어디 지역으로 여행을 계획하시나요?".pretendardAttributedString(style: .subtitle6)
        case .mood:
            extraLabel.isHidden = false
            underlineView.isHidden = false
            skipButton.isHidden = true
            extraLabel.attributedText = "분위기가 구체적일수록 좋아요!".pretendardAttributedString(style: .body2)
            requestPlaceHolder.attributedText = "지금 어떤 분위기의 여행이 가고싶나요?".pretendardAttributedString(style: .subtitle6)

            if let location = location {
                let baseText = "\(location)에서 찐친들과\n인스타그래머블하고 고즈넉한\n여행을 즐기고 싶어"
                exampleLabel.attributedText = baseText.pretendardAttributedString(style: .title4)
                exampleLabel.applyMultipleAttributes(styles: [
                    (target: "\(location)에서 찐친들", font: .PretendardStyle.title4.font, color: .mainYellow),
                    (target: "인스타그래머블", font: .PretendardStyle.title4.font, color: .mainYellow),
                    (target: "고즈넉한", font: .PretendardStyle.title4.font, color: .mainYellow)
                ])
            }
        case .video:
            requestPlaceHolder.attributedText = "참고하고 싶은 여행영상이 있나요?".pretendardAttributedString(style: .subtitle6)
            extraLabel.isHidden = true
            underlineView.isHidden = true
            skipButton.isHidden = false
//            extraLabel.text = "*영상 길이 최대 1분\n*참고하고 싶은 영상이 없다면, 다음 버튼을 눌러주세요."
//            extraLabel.snp.remakeConstraints {
//                $0.top.equalTo(exampleLabel.snp.bottom).offset(5)
//                $0.leading.equalTo(titleLabel)
//            }
            exampleLabel.attributedText = "www.gills-dream.com/\nshorts/gills1234".pretendardAttributedString(style: .title4, color: .mainYellow)
        }
    }
}
