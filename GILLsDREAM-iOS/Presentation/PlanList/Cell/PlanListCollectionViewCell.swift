//
//  PlanListCollectionViewCell.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import UIKit
import SnapKit
import RxSwift

final class PlanListCollectionViewCell: UICollectionViewCell {
    static let identifier = "PlanListCollectionViewCell"
    var disposeBag = DisposeBag()

    //MARK: views
    let planImageView = UIImageView()
    let isPinnedLabel = UILabel()
    let planTitle = UILabel()
    let planDate = UILabel()
    let detailButton = UIButton()
    
    //MARK: events
    var onConvertToPDF: (() -> Void)?
    var onUnpin: (() -> Void)?
    var onPin: (() -> Void)?
    var onShare: (() -> Void)?
    
    // MARK: init
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func setUpFoundation() {
        self.backgroundColor = .clear
    }
    
    private func setUpHierarchy() {
        [
            planImageView,
            isPinnedLabel,
            planTitle,
            planDate,
            detailButton
        ].forEach { self.addSubview($0) }
    }
    
    private func setUpUI() {
        planImageView.do {
            $0.layer.cornerRadius = 10
            $0.image = .imgDefaultGillSquare
            $0.contentMode = .scaleAspectFill
        }
        
        isPinnedLabel.do {
            $0.attributedText = "고정됨".pretendardAttributedString(style: .body2, color: .white)
            $0.isHidden = true
        }
        
        detailButton.do {
            $0.setImage(.imgDetail, for: .normal)
        }
    }
    
    private func setUpLayout() {
        planImageView.snp.makeConstraints {
            $0.verticalEdges.leading.equalToSuperview()
            $0.size.equalTo(86)
        }
        
        isPinnedLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.leading.equalTo(planImageView.snp.trailing).offset(7)
        }
        
        planTitle.snp.makeConstraints {
            $0.top.equalTo(isPinnedLabel.snp.bottom).offset(2)
            $0.leading.equalTo(isPinnedLabel)
        }
        
        planDate.snp.makeConstraints {
            $0.top.equalTo(planTitle.snp.bottom).offset(2)
            $0.leading.equalTo(isPinnedLabel).offset(1)
        }
        
        detailButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
    }
    
    private func setUpMenu(isPinned: Bool) {
        let pdfAction = UIAction(title: "PDF 변환",
                                 image: UIImage(systemName: "doc.fill")
        ) { [weak self] _ in
            self?.onConvertToPDF?()
        }
        
        let pinToggleAction = UIAction(
            title: isPinned ? "고정 해제" : "고정하기",
            image: UIImage(systemName: isPinned ? "pin.slash.fill" : "pin.fill")
        ) { [weak self] _ in
            isPinned ? self?.onUnpin?() : self?.onPin?()
        }

        let shareAction = UIAction(title: "공유하기",
                                   image: UIImage(systemName: "square.and.arrow.up")
        ) { [weak self] _ in
            self?.onShare?()
        }
        detailButton.showsMenuAsPrimaryAction = true
        detailButton.menu = UIMenu(title: "", children: [pdfAction,
                                                         pinToggleAction,
                                                         shareAction])
    }
}


extension PlanListCollectionViewCell {
    func configure(with model: Plan) {
        planTitle.attributedText = model.title.pretendardAttributedString(style: .subtitle5)
        planDate.attributedText = model.dateRange?.pretendardAttributedString(style: .body3) ?? "날짜 미정".pretendardAttributedString(style: .body3)
        isPinnedLabel.isHidden = !model.isPinned
        planImageView.image = model.imageURL ?? UIImage.imgDefaultGillSquare
        setUpMenu(isPinned: model.isPinned)
    }
}
