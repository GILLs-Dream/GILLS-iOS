//
//  TosAgreementView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import UIKit
import SnapKit
import Then

enum TosAgreement {
    case All
    case Other
}

final class TosAgreementView: UIView {
    let checkButton = UIButton()
    let tosLabel = UILabel()
    let detailButton = UIButton()
    
    private let agreementType: TosAgreement

    init(title: String, type: TosAgreement) {
        self.agreementType = type
        super.init(frame: .zero)
        tosLabel.attributedText = title.pretendardAttributedString(style: type == .All ? .body1 : .body2)
        setUpHierarchy()
        setUpUI()
        setUpLayout()
        applyAgreementTypeStyle()
        updateTextColor(isSelected: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpHierarchy() {
        [
            checkButton,
            tosLabel,
            detailButton
        ].forEach { self.addSubview($0) }
    }
    
    private func setUpUI() {
        self.do {
            $0.layer.cornerRadius = 10
        }
        
        checkButton.do {
            $0.setImage(.imgSelectedCheckbox, for: .selected)
        }
        
        detailButton.do {
            $0.setImage(.imgRightArrow, for: .normal)
        }
    }
    
    private func setUpLayout() {
        checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }
        
        tosLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(9)
            $0.centerY.equalToSuperview()
        }
        
        detailButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(22)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }
    }
    
    private func applyAgreementTypeStyle() {
        switch agreementType {
        case .All:
            self.backgroundColor = .white
            checkButton.setImage(.imgCheckbox1, for: .normal)
            detailButton.isHidden = true
        case .Other:
            self.backgroundColor = .mainBlue
            checkButton.setImage(.imgCheckbox2, for: .normal)
            detailButton.isHidden = false
        }
    }

}

// MARK: - External Update
extension TosAgreementView {
    func updateCheckState(isSelected: Bool) {
        checkButton.isSelected = isSelected
        updateTextColor(isSelected: isSelected)
        
        if agreementType == .All {
            self.backgroundColor = isSelected ? .mainOrange : .white
        }
    }
    
    private func updateTextColor(isSelected: Bool) {
        if agreementType == .All {
            tosLabel.textColor = isSelected ? .white : .black
        } else {
            tosLabel.textColor = .white
        }
    }
    
    func updateBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color
    }
}
