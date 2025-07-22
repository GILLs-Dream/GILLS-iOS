//
//  TravelPlaceCell.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/22/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelPlaceCell: UITableViewCell {
    static let identifier = "TravelPlaceCell"
    
    private let placeImageView = UIImageView()
    private let placeNameLabel = UILabel()
    let deleteButton = UIButton(type: .custom)
    
    var disposeBag = DisposeBag()
    let deleteTapped = PublishRelay<Void>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpFoundation()
        setUpHierarchy()
        setUpUI()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpFoundation() {
        self.backgroundColor = .clear
    }
    
    private func setUpHierarchy() {
        [
            placeImageView,
            placeNameLabel,
            deleteButton
        ].forEach { contentView.addSubview($0) }
    }
    
    private func setUpUI() {
        placeImageView.do {
            $0.layer.cornerRadius = 19
        }
        
        placeNameLabel.do {
            $0.font = .PretendardStyle.body2.font
            $0.textColor = .white
        }
        
        deleteButton.do {
            $0.setImage(.imgDeleteWhite, for: .normal)
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
            $0.size.equalTo(38)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let spacing: CGFloat = 8
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: spacing / 2, left: 0, bottom: spacing / 2, right: 0))
    }
}

extension TravelPlaceCell {
    func configure(with place: Place) {
        disposeBag = DisposeBag()
        
        placeImageView.image = place.imageURL
        placeNameLabel.text = place.name
        
        deleteButton.rx.tap
            .bind(to: deleteTapped)
            .disposed(by: disposeBag)
    }
}
