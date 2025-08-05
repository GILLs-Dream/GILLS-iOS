//
//  ToastView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/5/25.
//

import UIKit
import SnapKit
import Then

final class ToastView: UIView {
    // MARK: Views
    private let messageLabel = UILabel()
    
    // MARK: Init
    init(message: String) {
        super.init(frame: .zero)
        self.messageLabel.text = message
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
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 20
        alpha = 0.0
        
    }
    
    private func setUpHierarchy() {
        addSubview(messageLabel)
    }
    
    private func setUpUI() {
        messageLabel.do {
            $0.textColor = .white
            $0.font = .PretendardStyle.body1.font
            $0.textAlignment = .center
        }
    }
    
    private func setUpLayout() {
        messageLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
    }
}
