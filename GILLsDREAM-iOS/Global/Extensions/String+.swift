//
//  String+.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/17/25.
//

import UIKit

extension String {
    func pretendardAttributedString(style: UIFont.PretendardStyle,
                                    color: UIColor = .white) -> NSAttributedString {
        
        let font = style.font
        let lineHeight = font.pointSize * style.lineHeight / 100
        let kern = style.kern
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            .kern: kern
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    // 한글 조합 중 여부
    var isComposing: Bool {
        self.range(of: ".*[ㄱ-ㅎㅏ-ㅣ]+.*", options: .regularExpression) != nil
    }
    
}
