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
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    let contentContainerView = UIView()

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
            contentContainerView
        ].forEach { addSubview($0) }
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
        
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(travelDaysCollectionView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}

extension TravelResultView {
    func updateDaysHeight(_ height: CGFloat) {
        daysHeightConstraint?.update(offset: height)
        layoutIfNeeded()
    }
}
