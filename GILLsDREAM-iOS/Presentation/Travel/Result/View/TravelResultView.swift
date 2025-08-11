//
//  TravelResultView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/6/25.
//

import UIKit
import SnapKit

final class TravelResultView: UIView {
    // MARK: Properties
    private var daysHeightConstraint: Constraint?
    
    // MARK: Views
    let titleLabel = UILabel()
    let travelDaysCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 10
        layout.sectionInset = .zero
        layout.estimatedItemSize = .zero
        return UICollectionView(frame: .zero, collectionViewLayout: layout)}()
    let containerView = UIView()
    let travelDayResultView = TravelDayResultView()
    let summaryView = UILabel()
    let primaryButton = CustomButton(title: "지도로 확인하기")

    override init(frame: CGRect) {
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
            titleLabel,
            travelDaysCollectionView,
            containerView,
            primaryButton
        ].forEach { addSubview($0) }
        
        [
            travelDayResultView,
            summaryView,
        ].forEach { containerView.addSubview($0) }
    }

    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "강릉 트로피컬 썸머 여행".pretendardAttributedString(style: .title1)
        }
        
        travelDaysCollectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.register(TravelDaysCollectionViewCell.self,
                        forCellWithReuseIdentifier: TravelDaysCollectionViewCell.identifier)
        }
        
        summaryView.do {
            $0.attributedText = "요약 정보를 준비 중입니다.".pretendardAttributedString(style: .body1)
            $0.numberOfLines = 0
            $0.isHidden = true
        }
    }

    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(15)
            $0.leading.equalToSuperview().offset(24)
        }
        
        travelDaysCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(40)
            self.daysHeightConstraint = $0.height.equalTo(28).constraint
        }
        
        primaryButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(travelDaysCollectionView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(primaryButton.snp.top).offset(-16)
        }
        
        travelDayResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        summaryView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
    }
}

extension TravelResultView {
    enum ContentMode {
        case day
        case summary
    }
    
    func setContentMode(_ mode: ContentMode) {
        switch mode {
        case .day:
            travelDayResultView.isHidden = false
            summaryView.isHidden = true
            primaryButton.updateTitle("지도로 확인하기")
        case .summary:
            travelDayResultView.isHidden = true
            summaryView.isHidden = false
            primaryButton.updateTitle("여행 저장하기")
        }
    }
    
    func updateDaysHeight(_ height: CGFloat) {
        daysHeightConstraint?.update(offset: height)
        layoutIfNeeded()
    }
}
