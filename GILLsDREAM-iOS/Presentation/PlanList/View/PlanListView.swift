//
//  PlanListView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import UIKit
import SnapKit

final class PlanListView: UIView {
    private let titleLabel = UILabel()
    let noPlanLabel = UILabel()
    lazy var myPlanCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: setUpCollectionViewFlowLayout())
        return collectionView
    }()
    
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
    
    private func setUpCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 25)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 86)
        return layout
    }
    
    private func setUpFoundation() {
        self.backgroundColor = .clear
    }
    
    private func setUpHierarchy() {
        [
            titleLabel,
            noPlanLabel,
            myPlanCollectionView
        ].forEach { self.addSubview($0) }
    }
    
    private func setUpUI() {
        titleLabel.do {
            $0.attributedText = "여행목록".pretendardAttributedString(style: .body0)
        }
        
        noPlanLabel.do {
            $0.numberOfLines = 2
            $0.textAlignment = .center
            $0.attributedText = "현재 생성된 여행이 없습니다.\n(아래로 당겨서 새로고침하기)".pretendardAttributedString(style: .body0)
            $0.isHidden = true
        }
        
        myPlanCollectionView.do {
            $0.backgroundColor = .clear
            $0.register(PlanListCollectionViewCell.self,
                        forCellWithReuseIdentifier: PlanListCollectionViewCell.identifier)
            $0.showsVerticalScrollIndicator = false
        }
    }
    
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.centerX.equalToSuperview()
        }
        
        noPlanLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    
        myPlanCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
    }
}
