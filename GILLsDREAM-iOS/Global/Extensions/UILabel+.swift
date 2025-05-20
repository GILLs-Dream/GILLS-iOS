//
//  UILabel+.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/17/25.
//

import UIKit

extension UILabel {
    func applyMultipleAttributes(styles: [(target: String, font: UIFont?, color: UIColor?)]) {
        guard let currentAttrText = attributedText else { return }
        let mutableAttrString = NSMutableAttributedString(attributedString: currentAttrText)
        let fullText = currentAttrText.string

        styles.forEach { style in
            let range = (fullText as NSString).range(of: style.target)
            mutableAttrString.addAttributes([
                .font: style.font as Any,
                .foregroundColor: style.color as Any
            ], range: range)
        }
        attributedText = mutableAttrString
    }
}
