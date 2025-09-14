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
    let saveButton = CustomButton(title: "여행 저장하기")
    let loadingLabel = UILabel()

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
            saveButton
        ].forEach { addSubview($0) }
        
        [
            travelDayResultView,
            summaryView,
            loadingLabel
        ].forEach { containerView.addSubview($0) }
    }

    private func setUpUI() {
        titleLabel.do {
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        
        travelDaysCollectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.register(TravelDaysCollectionViewCell.self,
                        forCellWithReuseIdentifier: TravelDaysCollectionViewCell.identifier)
        }
        
        summaryView.do {
            $0.attributedText = "요약 정보를 불러오고 있습니다. (약 10초 소요)".pretendardAttributedString(style: .body1)
            $0.numberOfLines = 0
            $0.isHidden = true
        }
        
        loadingLabel.do {
            $0.attributedText = "여행 계획을 불러오고 있습니다.\n(최대 10초 소요)".pretendardAttributedString(style: .body1)
            $0.textAlignment = .center
            $0.numberOfLines = 2
            $0.isHidden = true
        }
    }

    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        travelDaysCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(40)
            self.daysHeightConstraint = $0.height.equalTo(28).constraint
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(travelDaysCollectionView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }
        
        travelDayResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        summaryView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        loadingLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

extension TravelResultView {
    func configure(plan: PlanResult) {
        titleLabel.attributedText = plan.title.pretendardAttributedString(style: .title2)
    }
    
    func configure(summary: PlanSummary) {
        summaryView.attributedText = summary.summary.pretendardAttributedString(style: .body1)
    }
    
    enum ContentMode {
        case day
        case summary
    }
    
    func setContentMode(_ mode: ContentMode) {
        switch mode {
        case .day:
            travelDayResultView.isHidden = false
            summaryView.isHidden = true
            saveButton.updateTitle("여행 저장하기")
        case .summary:
            travelDayResultView.isHidden = true
            summaryView.isHidden = false
            saveButton.updateTitle("여행 저장하기")
        }
    }
    
    func updateDaysHeight(_ height: CGFloat) {
        daysHeightConstraint?.update(offset: height)
        layoutIfNeeded()
    }
}
