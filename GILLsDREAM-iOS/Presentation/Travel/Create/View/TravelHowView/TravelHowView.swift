//
//  TravelHowView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/23/25.
//

import UIKit

final class TravelHowView: UIView {
    // MARK: Views
    let headerView: TravelHeaderView
    private let titleLabel = UILabel()
    private let transportLabel = UILabel()
    let transportOptionView = TransportOptionView()
    private let categoryLabel = UILabel()
    let categoryOptionView = CategoryOptionView()
    lazy var doneButton = CustomButton()

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
            transportLabel,
            transportOptionView,
            categoryLabel,
            categoryOptionView,
            doneButton
        ].forEach { self.addSubview($0) }
    }

    // MARK: setUpUI
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "STEP 4. 여행 스타일을 선택해주세요.".pretendardAttributedString(style: .body1)
        }
        
        transportLabel.do {
            $0.attributedText = "✪  주요 교통 수단 (복수 선택) :".pretendardAttributedString(style: .body2)
        }
        
        categoryLabel.do {
            $0.attributedText = "✪  선호 카테고리 (복수 선택) :".pretendardAttributedString(style: .body2)
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

        transportLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(48)
        }
        
        transportOptionView.snp.makeConstraints {
            $0.top.equalTo(transportLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(70)
            $0.height.equalTo(38)
        }

        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(transportOptionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(48)
        }
        
        categoryOptionView.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(60)
            $0.height.equalTo(119)
        }

        doneButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
    }
}
