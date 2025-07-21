//
//  TravelWhereView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit

final class TravelWhereView: UIView {
    let headerView: TravelHeaderView
    private let titleLabel = UILabel()
    let pageLabel = UILabel()
    lazy var addButton = UIButton()
    lazy var previousButton = CustomButton(title: "이전")
    lazy var nextButton = CustomButton()
    private let placeStackView = UIStackView()

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
            placeStackView,
            addButton,
            previousButton,
            nextButton,
            pageLabel
        ].forEach { addSubview($0) }
    }

    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "STEP 3. 생각해둔 여행지가 있다면 추가해주세요.".pretendardAttributedString(style: .body1)
        }
        
        placeStackView.do {
            $0.axis = .vertical
            $0.spacing = 10
            $0.distribution = .fill
            $0.alignment = .fill
        }
        
        addButton.do {
            $0.setAttributedTitle("✚  내 지도에서 추가하기 (최대 5개)".pretendardAttributedString(style: .body2), for: .normal)
        }
        
        pageLabel.do {
            $0.attributedText = "1/2".pretendardAttributedString(style: .body2)
        }
        
        previousButton.do {
            $0.isHidden = true
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
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(50)
        }
        
        placeStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(43)
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
    
    func updatePlaceStack(with places: [Place], onDelete: @escaping (Place) -> Void) {
        placeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for place in places {
            let cell = TravelPlaceCell(place: place)
            cell.onDelete = {
                onDelete(place)
            }
            placeStackView.addArrangedSubview(cell)
            
            cell.snp.makeConstraints {
                $0.height.equalTo(38)
            }
        }

        addButton.snp.remakeConstraints {
            $0.top.equalTo(placeStackView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(50)
        }
    }
    
    func updateButtons(for page: Int) {
        if page == 0 {
            previousButton.isHidden = true
            nextButton.snp.remakeConstraints {
                $0.height.equalTo(51)
                $0.horizontalEdges.equalToSuperview().inset(43)
                $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            }
        } else {
            previousButton.isHidden = false
            previousButton.snp.remakeConstraints {
                $0.height.equalTo(51)
                $0.leading.equalToSuperview().inset(43)
                $0.trailing.equalTo(self.snp.centerX).offset(-10)
                $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            }
            nextButton.snp.remakeConstraints {
                $0.height.equalTo(51)
                $0.leading.equalTo(self.snp.centerX).offset(10)
                $0.trailing.equalToSuperview().inset(43)
                $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            }
        }
    }
}
