//
//  TravelWhenView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/16/25.
//

import UIKit

let titleText = "무더위의 여름에\n트로피컬한 분위기의 저렴이\n강릉 여행을 즐기고 싶어."

final class TravelWhenView: UIView {
    // MARK: Views
    let headerView: TravelHeaderView
    private let titleLabel = UILabel()
    private let travelDurationView = UIView()
    private let travelDateView = UIView()
    
    let nextButton = CustomButton()
    
    override init(frame: CGRect) {
        self.headerView = TravelHeaderView(titleText: titleText)
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
            headerView,
            titleLabel,
            nextButton
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "STEP 1. 여행 기간 및 날짜를 입력해주세요.".pretendardAttributedString(style: .body1)
        }
        
        nextButton.do {
            $0.isHidden = true
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            $0.leading.equalToSuperview().offset(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(24)
            $0.leading.equalTo(headerView)
        }
        
        nextButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
    }
}
