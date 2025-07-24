//
//  TransportOptionView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/23/25.
//

import UIKit

final class TransportOptionView: UIView {
    var transportButtons: [CustomSelectableButton] {
        return [
            walkButton, publicTransportButton,
            taxiButton, bikeButton,
        ]
    }
    
    private lazy var walkButton = CustomSelectableButton(title: "도보")
    private lazy var publicTransportButton = CustomSelectableButton(title: "대중교통")
    private lazy var taxiButton = CustomSelectableButton(title: "자동차")
    private lazy var bikeButton = CustomSelectableButton(title: "자전거")

    private lazy var row1 = UIStackView(arrangedSubviews: [walkButton, publicTransportButton])
    private lazy var row2 = UIStackView(arrangedSubviews: [taxiButton, bikeButton])
    private lazy var stackView = UIStackView(arrangedSubviews: [row1, row2])

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
            row1,
            row2
        ].forEach {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.distribution = .fillEqually
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = 13
            $0.distribution = .fillEqually
        }
    }
    
    private func setUpLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
