//
//  BackgroundView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/14/25.
//

import UIKit

final class BackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    func setupGradient() {
        //19시-02시
        let nightColors: [CGColor] = [
            UIColor.black.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.subBlue.cgColor,
            UIColor.subPurple.cgColor,
            UIColor.mainOrange.cgColor
        ]
        
        //02시-07시
        let night2dayColors: [CGColor] = [
            UIColor.black.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.subBlue.cgColor,
            UIColor.subPurple.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor
        ]
        
        //07시-11시
        let middleColors: [CGColor] = [
            UIColor.black.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.subBlue.cgColor,
            UIColor.subPurple.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor
        ]
        
        //11시-14시
        let middle2dayColors: [CGColor] = [
            UIColor.black.cgColor,
            UIColor.mainBlue.cgColor,
            UIColor.subBlue.cgColor,
            UIColor.subPurple.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor
        ]
        
        //14시-19시
        let dayColors: [CGColor] = [
            UIColor.mainBlue.cgColor,
            UIColor.subBlue.cgColor,
            UIColor.subPurple.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor,
            UIColor.mainOrange.cgColor
        ]
        
        gradientLayer.frame = self.bounds
        gradientLayer.colors = nightColors
        self.layer.addSublayer(gradientLayer)

        // CAKeyframeAnimation 사용
        let colorAnimation = CAKeyframeAnimation(keyPath: "colors")
        colorAnimation.values = [nightColors, night2dayColors, middleColors, middle2dayColors, dayColors]
        colorAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]  // 각 단계의 타이밍 (0~1 사이)
        colorAnimation.duration = 10 //43200 // 12(시간) * 60 * 60
        colorAnimation.autoreverses = true //역재생 설정하기
        colorAnimation.calculationMode = .linear  // 부드럽게 변화
        colorAnimation.repeatCount = .infinity

        gradientLayer.add(colorAnimation, forKey: "night2day-Animation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds // 화면 회전 대비
    }
}
