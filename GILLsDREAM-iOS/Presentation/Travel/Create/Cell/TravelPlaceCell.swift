//
//  TravelPlaceCell.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/21/25.
//

import UIKit


final class TravelPlaceCell: UIView {
    
    private let placeImageView = UIImageView()
    private let placeNameLabel = UILabel()
    private let deleteButton = UIButton(type: .close)
    var onDelete: (() -> Void)?

    init(place: Place) {
        super.init(frame: .zero)
        placeImageView.image = place.imageURL
        placeNameLabel.attributedText = place.name.pretendardAttributedString(style: .body1)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        setUpHierarchy()
        setUpUI()
        setUpLayout()
    }
    
    private func setUpHierarchy() {
        [
            placeImageView,
            placeNameLabel,
            deleteButton
        ].forEach { self.addSubview($0) }
    }
    
    private func setUpUI() {
        placeImageView.do {
            $0.layer.cornerRadius = 19
        }
        
        deleteButton.do {
            $0.setImage(.imgDelete, for: .normal)
        }
    }
    
    private func setUpLayout() {
        placeImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(38)
        }
        
        placeNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(placeImageView.snp.trailing).offset(12)
        }

        deleteButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }

    @objc private func deleteTapped() {
        onDelete?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

