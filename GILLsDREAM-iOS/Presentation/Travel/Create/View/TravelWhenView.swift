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
    let travelDurationView = TravelCustomView(title: "✪  여행 기간:",
                                                      inputMode: .numberPicker(range: 1...7),
                                                      unit: "일",
                                                      detail: "* 최대 7일")
    let travelDateView = TravelCustomView(title: "✪  여행 날짜:",
                                                  inputMode: .datePicker)
    lazy var pendingButton = UIButton()
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
            travelDurationView,
            travelDateView,
            pendingButton,
            nextButton
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "STEP 1. 여행 기간 및 날짜를 입력해주세요.".pretendardAttributedString(style: .body1)
        }
        
        pendingButton.do {
            var config = UIButton.Configuration.plain()
            config.imagePadding = 8
            $0.setImage(.imgCircle, for: .normal)
            $0.setAttributedTitle("여행날짜는 미정입니다.".pretendardAttributedString(style: .body3), for: .normal)
            $0.configuration = config
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
        
        travelDurationView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        travelDateView.snp.makeConstraints {
            $0.top.equalTo(travelDurationView.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        pendingButton.snp.makeConstraints {
            $0.top.equalTo(travelDateView.snp.bottom).offset(4)
            $0.leading.equalTo(travelDateView).offset(80)
            $0.height.equalTo(14)
            $0.width.equalTo(200)
        }
        
        nextButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
    }
}
