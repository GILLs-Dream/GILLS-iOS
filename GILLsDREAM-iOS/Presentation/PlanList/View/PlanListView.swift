//
//  PlanListView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import UIKit
import SnapKit

final class PlanListView: UIView {
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
        self.addSubview(myPlanCollectionView)
    }
    
    private func setUpUI() {
        myPlanCollectionView.do {
            $0.backgroundColor = .clear
            $0.register(PlanListCollectionViewCell.self,
                        forCellWithReuseIdentifier: PlanListCollectionViewCell.identifier)
            $0.showsVerticalScrollIndicator = false
        }
    }
    
    private func setUpLayout() {
        myPlanCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
