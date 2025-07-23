//
//  CategoryOptionView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/23/25.
//

import UIKit

final class CategoryOptionView: UIView {
    var categoryButtons: [CustomButton] {
        return [
            sightseeingButton, cultureButton,
            eventButton, leisureButton,
            shoppingButton, foodButton
        ]
    }
    
    private lazy var sightseeingButton = CustomButton(title: "관광")
    private lazy var cultureButton = CustomButton(title: "문화")
    private lazy var eventButton = CustomButton(title: "행사")
    private lazy var leisureButton = CustomButton(title: "레포츠")
    private lazy var shoppingButton = CustomButton(title: "쇼핑")
    private lazy var foodButton = CustomButton(title: "음식")

    private lazy var row1 = UIStackView(arrangedSubviews: [sightseeingButton, cultureButton])
    private lazy var row2 = UIStackView(arrangedSubviews: [eventButton, leisureButton])
    private lazy var row3 = UIStackView(arrangedSubviews: [shoppingButton, foodButton])
    private lazy var stackView = UIStackView(arrangedSubviews: [row1, row2, row3])

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
    
    private func setUpFoundation() {
        backgroundColor = .clear
    }
    
    private func setUpHierarchy() {
        addSubview(stackView)
    }


    private func setUpUI() {
        [
            sightseeingButton,
            cultureButton,
            eventButton,
            leisureButton,
            shoppingButton,
            foodButton
        ].forEach {
            $0.layer.cornerRadius = 17.5
            $0.titleLabel?.font = .PretendardStyle.body2.font
        }
        
        [
            row1,
            row2,
            row3
        ].forEach {
            $0.axis = .horizontal
            $0.spacing = 26
            $0.distribution = .fillEqually
        }
        
        stackView.do {
            $0.axis = .vertical
            $0.spacing = 7
            $0.distribution = .fillEqually
        }
    }
    
    private func setUpLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
