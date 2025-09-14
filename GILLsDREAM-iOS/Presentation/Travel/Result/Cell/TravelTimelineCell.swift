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

    // 사이즈/간격 상수
    private enum Const {
        static let image: CGFloat = 56   // 이미지 높이(H)
        static let lineWidth: CGFloat = 3
        static let vGap: CGFloat = 0     // 점선과 이미지 간격
        static let inset: CGFloat = 0   // 위/아래 여백
        static let hInset: CGFloat = 0  // 좌우 여백
    }
    
    private var dottedLineHeightConstraint: Constraint?

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
        dottedLine.isHidden = false
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
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .lightGray
        }
        titleLabel.do {
            $0.numberOfLines = 1
        }
        distanceLabel.do {
            $0.isHidden = true
            $0.numberOfLines = 1
        }
        dottedLine.do {
            $0.image = .imgDottedLine // 세로 점선 이미지
            $0.contentMode = .scaleToFill
        }
    }

    private func setUpLayout() {
        // 점선: 높이 = 이미지 높이
        dottedLine.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Const.inset)
            $0.leading.equalToSuperview().offset(Const.hInset + Const.image/2 - Const.lineWidth/2)
            $0.width.equalTo(Const.lineWidth)
            self.dottedLineHeightConstraint = $0.height.equalTo(Const.image).constraint
        }

        // 점선 중앙에 이동거리 라벨
        distanceLabel.snp.makeConstraints {
            $0.centerY.equalTo(dottedLine)
            $0.leading.equalTo(dottedLine.snp.trailing).offset(10)
            $0.trailing.lessThanOrEqualToSuperview().inset(Const.hInset)
        }

        // 이미지
        placeImageView.snp.makeConstraints {
            $0.top.equalTo(dottedLine.snp.bottom).offset(Const.vGap) // 점선 아래 배치
            $0.leading.equalToSuperview().offset(Const.hInset)
            $0.size.equalTo(Const.image)
        }

        // 타이틀
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(placeImageView)
            $0.leading.equalTo(placeImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(Const.hInset)
        }

        // 셀 바닥 고정 → 오토 높이 안정화
        contentView.snp.makeConstraints {
            $0.bottom.equalTo(placeImageView.snp.bottom).offset(Const.inset) // 셀 높이 ≈ 2H + vGap + inset*2
        }
    }
}

// MARK: - Configure
extension TravelTimelineCell {
    /// 1번째(시작) 셀
    func configureStart(place: PlanPlace) {
        titleLabel.attributedText = place.name.pretendardAttributedString(style: .body0)
        distanceLabel.isHidden = true
        dottedLine.isHidden = true // 첫 셀만 점선 숨김
        dottedLineHeightConstraint?.update(offset: 0)
        setNeedsLayout()
    }

    /// 2번째 이후(이전→현재) 셀
    func configureRoute(_ route: PlanRoute) {
        titleLabel.attributedText = route.to.name.pretendardAttributedString(style: .body0)

        // m→km, sec→min
        let km = max(0, Int(round(Double(route.distance) / 1000.0)))
        let min = max(0, Int(round(Double(route.time) / 60.0)))
        let text = "\(km)km, 약 \(min)분"

        dottedLineHeightConstraint?.update(offset: 56)
        distanceLabel.attributedText = text.pretendardAttributedString(style: .body3)
        distanceLabel.isHidden = false
        dottedLine.isHidden = false
        setNeedsLayout()
    }
}
