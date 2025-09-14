//
//  TravelDayResultView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/10/25.
//

import UIKit
import SnapKit

final class TravelDayResultView: UIView {
    // MARK: Views
    let containerView = UIView()
    let travelTimelineTableView = UITableView()
    let transportationDetailLabel = UILabel()

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
            containerView,
            transportationDetailLabel
        ].forEach { addSubview($0) }
        
        containerView.addSubview(travelTimelineTableView)
    }

    private func setUpUI() {
        containerView.do {
            $0.layer.cornerRadius = 30
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
            $0.backgroundColor = .clear
            $0.clipsToBounds = true
        }
        
        travelTimelineTableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.isScrollEnabled = true
            $0.sectionHeaderHeight = 15
            $0.estimatedRowHeight = 80
            $0.rowHeight = UITableView.automaticDimension
            $0.showsVerticalScrollIndicator = false
            $0.register(TravelTimelineCell.self,
                        forCellReuseIdentifier: TravelTimelineCell.identifier)
        }
    }

    private func setUpLayout() {
        containerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(60)
        }
        
        travelTimelineTableView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        //TODO: Label api 연결
//        transportationDetailLabel.snp.makeConstraints {
//            $0.top.equalTo(containerView.snp.bottom).offset(5)
//            $0.leading.equalToSuperview().offset(5)
//        }
    }
}
