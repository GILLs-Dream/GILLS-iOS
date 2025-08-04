//
//  CustomModelView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import UIKit
import SnapKit

final class CustomModalView: UIView {
    // MARK: Views
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let horizontalDividerLine = UIView()
    private let verticalDividerLine = UIView()
    private let confirmButton = UIButton()
    private let cancelButton = UIButton()
    
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    // MARK: Init
    init(title: String, confirmTitle: String) {
        super.init(frame: .zero)
        configure(title: title, confirmTitle: confirmTitle)
        setUpFoundation()
        setUpHierarchy()
        setUpUI()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setUpFoundation
    private func setUpFoundation() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    // MARK: setUpHierarchy
    private func setUpHierarchy() {
        self.addSubview(containerView)

        [
            titleLabel,
            horizontalDividerLine,
            verticalDividerLine,
            confirmButton,
            cancelButton
        ].forEach { containerView.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        containerView.do {
            $0.backgroundColor = .mainBlue
            $0.layer.cornerRadius = 20
        }
        
        titleLabel.do {
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        horizontalDividerLine.do {
            $0.backgroundColor = .white
        }
        
        verticalDividerLine.do {
            $0.backgroundColor = .white
        }
        
        confirmButton.do {
            $0.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        }
        
        cancelButton.do {
            $0.setAttributedTitle("취소".pretendardAttributedString(style: .body2), for: .normal)
            $0.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(45)
            $0.height.equalTo(168)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(containerView.snp.top).offset(64)
            $0.centerX.equalToSuperview()
        }
        
        horizontalDividerLine.snp.makeConstraints {
            $0.top.equalToSuperview().offset(128)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        verticalDividerLine.snp.makeConstraints {
            $0.top.equalTo(horizontalDividerLine.snp.bottom)
            $0.centerX.bottom.equalToSuperview()
            $0.width.equalTo(1)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(horizontalDividerLine.snp.bottom)
            $0.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(verticalDividerLine.snp.leading)
        }

        cancelButton.snp.makeConstraints {
            $0.top.equalTo(horizontalDividerLine.snp.bottom)
            $0.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(verticalDividerLine.snp.trailing)
        }
    }
    
    // MARK: configure
    private func configure(title: String, confirmTitle: String) {
        titleLabel.attributedText = title.pretendardAttributedString(style: .body1)
        confirmButton.setAttributedTitle(confirmTitle.pretendardAttributedString(style: .body2), for: .normal)
    }
    
    // MARK: Actions
    @objc private func confirmTapped() {
        onConfirm?()
        self.removeFromSuperview()
    }
    
    @objc private func cancelTapped() {
        onCancel?()
        self.removeFromSuperview()
    }
}
