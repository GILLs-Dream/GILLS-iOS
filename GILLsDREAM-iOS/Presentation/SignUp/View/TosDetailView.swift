//
//  TosDetailView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

// TosDetailViewController.swift
import UIKit
import SnapKit

final class TosDetailView: UIView {
    
    let titleLabel = UILabel()
    let contentLabel = UITextView()
    let closeButton = UIButton()
    
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
        self.backgroundColor = .white
    }
    
    private func setUpHierarchy() {
        [
            titleLabel,
            contentLabel,
            closeButton
        ].forEach { self.addSubview($0) }
    }
    
    private func setUpUI() {
        titleLabel.do {
            $0.font = .PretendardStyle.subtitle5.font
        }
        
        contentLabel.do {
            $0.font = .PretendardStyle.body1.font
            $0.isEditable = false
        }
        
        closeButton.do {
            $0.setImage(.imgDelete, for: .normal)
        }
    }
    
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
