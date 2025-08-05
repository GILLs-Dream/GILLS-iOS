//
//  TravelWhereView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit
import SnapKit

final class TravelWhereView: UIView {
    var addButtonTopConstraint: Constraint?
    
    let headerView: TravelHeaderView
    private let titleLabel = UILabel()
    let placeTableView = UITableView()
    let stayTableView = UITableView()
    let pageLabel = UILabel()
    lazy var addButton = UIButton()
    lazy var previousButton = CustomButton(title: "이전")
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

    private func setUpFoundation() {
        backgroundColor = .clear
    }

    private func setUpHierarchy() {
        [
            headerView,
            titleLabel,
            placeTableView,
            stayTableView,
            addButton,
            previousButton,
            nextButton,
            pageLabel
        ].forEach { addSubview($0) }
    }

    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "STEP 3. 생각해둔 여행지가 있다면 추가해주세요. (선택)".pretendardAttributedString(style: .body1)
        }
        
        placeTableView.do {
            $0.backgroundColor = .clear
            $0.allowsSelection = false
            $0.isScrollEnabled = false
        }
        
        stayTableView.do {
            $0.backgroundColor = .clear
            $0.allowsSelection = false
            $0.isScrollEnabled = false
            $0.isHidden = true
        }
        
        addButton.do {
            $0.setAttributedTitle("✚  내 지도에서 추가하기 (최대 5개)".pretendardAttributedString(style: .body2), for: .normal)
        }
        
        pageLabel.do {
            $0.attributedText = "1/2".pretendardAttributedString(style: .body2)
        }
    }

    private func setUpLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            $0.leading.equalToSuperview().offset(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(24)
            $0.leading.equalTo(headerView)
        }
        
        placeTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.height.equalTo(0)
        }
        
        stayTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.height.equalTo(0)
        }
        
        addButton.snp.makeConstraints {
            self.addButtonTopConstraint = $0.top.equalTo(placeTableView.snp.bottom).offset(16).constraint
            $0.leading.equalToSuperview().inset(50)
        }
        
        previousButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.leading.equalToSuperview().inset(43)
            $0.trailing.equalTo(self.snp.centerX).offset(-7)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }

        nextButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.leading.equalTo(self.snp.centerX).offset(7)
            $0.trailing.equalToSuperview().inset(43)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
        
        pageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).inset(-10)
        }
    }
}

extension TravelWhereView {
    func updateTitle(text: String) {
        titleLabel.attributedText = text.pretendardAttributedString(style: .body1)
    }
    
    func updatePage(text: String) {
        pageLabel.attributedText = text.pretendardAttributedString(style: .body2)
    }
}
