//
//  UIButton+.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 6/3/25.
//

import UIKit

extension UIButton {
    func setButtonStyle(
        title: String,
        titleColor: UIColor,
        backgroundColor: UIColor,
        font: UIFont = .PretendardStyle.body0.font
    ) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.font = font
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
    }
}
