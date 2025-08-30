//
//  TravelTimelineCell.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/11/25.
//

import UIKit
import SnapKit

final class TravelTimelineCell: UITableViewCell {
    //MARK: Properties
    static let identifier = "TravelTimelineCell"
        
    //MARK: Views
    private let placeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let distanceLabel = UILabel()
    private let dottedLine = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpFoundation()
        setUpUI()
        setUpHierarchy()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        distanceLabel.attributedText = nil
        distanceLabel.isHidden = true
    }
    
    private func setUpFoundation() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    private func setUpHierarchy() {
        [
            placeImageView,
            titleLabel,
            dottedLine,
            distanceLabel
        ].forEach { contentView.addSubview($0) }
    }
    
    private func setUpUI() {
        placeImageView.do {
            $0.image = .imgDefaultGillSquare
            $0.layer.cornerRadius = 10
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .lightGray
        }
        
        distanceLabel.do {
            $0.isHidden = true
        }
        
        dottedLine.do {
            $0.image = .imgDottedLine
        }
    }
    
    private func setUpLayout() {
        placeImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(placeImageView)
            $0.leading.equalTo(placeImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(24)
        }
        
        dottedLine.snp.makeConstraints {
            $0.top.equalTo(placeImageView.snp.bottom)
            $0.bottom.equalTo(contentView.snp.bottom)
            $0.centerX.equalTo(placeImageView)
            $0.width.equalTo(2)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.centerY.equalTo(dottedLine)
            $0.leading.equalTo(placeImageView.snp.centerX).offset(10)
        }
    }
}

extension TravelTimelineCell {
    func configure(item: PlaceResult, isLast: Bool) {
        titleLabel.attributedText = item.title.pretendardAttributedString(style: .body0)
        
        let text = "\(item.distanceToNextKm ?? 0)km, 약 \(item.timeToNextMin ?? 0)분"
        
        if !isLast {
            distanceLabel.attributedText = text.pretendardAttributedString(style: .body3)
            distanceLabel.isHidden = false
        } else {
            distanceLabel.isHidden = true
        }
        
        // 마지막 셀일 경우 점선 숨김
        dottedLine.isHidden = isLast
        layoutIfNeeded()
    }
}
