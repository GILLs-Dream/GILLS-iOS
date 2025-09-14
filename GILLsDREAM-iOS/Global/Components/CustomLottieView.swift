//
//  CustomLottieView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/29/25.
//

import UIKit
import Lottie
import SnapKit

final class CustomLottieView: UIView {
    
    // MARK: Views
    let lottieView = LottieAnimationView(name: "gill's dream")
    let textLabel = UILabel()
    
    // MARK: Init
    init(text: String) {
        super.init(frame: .zero)
        setUpFoundation()
        setUpHierachey()
        setUpUI()
        setUpLayout()
        setText(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    private func setUpFoundation() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.isHidden = true
    }
    
    private func setUpHierachey() {
        addSubview(lottieView)
        addSubview(textLabel)
    }
    
    private func setUpUI() {
        lottieView.do {
            $0.loopMode = .loop
            $0.animationSpeed = 4
            $0.contentMode = .scaleAspectFill
        }
        
        textLabel.do {
            $0.numberOfLines = 3
            $0.textAlignment = .center
            $0.font = .PretendardStyle.subtitle1.font
            $0.textColor = .white
        }
    }
    
    private func setUpLayout() {
        lottieView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints {
            $0.top.equalTo(lottieView.snp.bottom).offset(-50)
            $0.centerX.equalToSuperview()
        }
    }
}

// MARK: Public Methods
extension CustomLottieView {
    func setText(_ text: String) {
        let attrString = NSMutableAttributedString(string: text)
        textLabel.attributedText = attrString
        textLabel.applyMultipleAttributes(styles: [
            (
                target: "(최대 1분 소요)",
                font: .PretendardStyle.body1.font,
                color: .white
            )
        ])
    }

    func startAnimating() {
        self.isHidden = false
        self.lottieView.play()
    }

    func stopAnimating() {
        self.isHidden = true
        self.lottieView.stop()
    }
}
