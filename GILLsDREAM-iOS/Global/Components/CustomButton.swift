//
//  CustomButton.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/10/25.
//

import UIKit

final class CustomButton: UIButton {

    // MARK: Properties
    private var theme: CustomButton.Theme
    private var title: String

    init(theme: Theme = .transparent, title: String = "다음", enable: Bool = true) {
        self.theme = theme
        self.title = title
        super.init(frame: .zero)
        self.isEnabled = enable
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: setUpUI
    private func setupUI() {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = .PretendardStyle.body0.font
        self.backgroundColor = theme.backgroundColor
        self.layer.borderColor = theme.outlineColor.cgColor
        self.layer.cornerRadius = 25
        self.layer.borderWidth = 1
    }
    
    func updateTheme(_ theme: Theme) {
        self.theme = theme
        setupUI()
    }
    
    func updateTitle(_ title: String) {
        self.title = title
    }
}

// MARK: - Interface
extension CustomButton {
    enum Theme {
        case transparent
        case color

        var backgroundColor: UIColor {
            switch self {
            case .transparent:
                return .clear
            case .color:
                return .mainOrange
            }
        }
        
        var outlineColor: UIColor {
            switch self {
            case .transparent:
                return .white
            case .color:
                return .clear
            }
        }
    }
}
