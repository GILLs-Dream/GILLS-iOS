//
//  TravelDaysCollectionViewCell.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/7/25.
//

import UIKit
import SnapKit

final class TravelDaysCollectionViewCell: UICollectionViewCell {
    //MARK: Properties
    static let identifier = "TravelDaysCollectionViewCell"
    
    //MARK: Views
    private let dayButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpHierarchy()
        setupUI()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpHierarchy() {
        contentView.addSubview(dayButton)
    }
    

    private func setupUI() {
        dayButton.do {
            $0.layer.cornerRadius = 14
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
            $0.contentVerticalAlignment = .center
            $0.contentHorizontalAlignment = .center
            $0.isUserInteractionEnabled = false // 셀 터치로 처리하므로 비활성화
        }
    }
    
    private func setUpLayout() {
        dayButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TravelDaysCollectionViewCell {
    func configure(title: String, isSelected: Bool) {
        let titleColor = isSelected ? UIColor.black : UIColor.white
        let attributed = title.pretendardAttributedString(style: .body1, color: titleColor)
        dayButton.setAttributedTitle(attributed, for: .normal)
        dayButton.backgroundColor = isSelected ? .white : .clear
    }
}
