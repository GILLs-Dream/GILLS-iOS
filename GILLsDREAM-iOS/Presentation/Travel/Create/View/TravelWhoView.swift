//
//  TravelWhoView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit

final class TravelWhoView: UIView {
    // MARK: Views
    let headerView: TravelHeaderView
    private let titleLabel = UILabel()
    let travelPaxView = TravelCustomView(title: "✪  인원수:",
                                                      inputMode: .numberPicker(range: 1...20),
                                                      unit: "명",)
    let travelWhoView = TravelCustomView(title: "✪  누구와:",
                                         inputMode: .keyboard,
                                         detail: "* 선택사항입니다.")
    lazy var nextButton = CustomButton()
    
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
            travelPaxView,
            travelWhoView,
            nextButton
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "STEP 2. 누구와 여행을 가는지 입력해주세요.".pretendardAttributedString(style: .body1)
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
        
        travelPaxView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        travelWhoView.snp.makeConstraints {
            $0.top.equalTo(travelPaxView.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        nextButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
    }
}
