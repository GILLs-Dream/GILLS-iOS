//
//  UIView+.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import UIKit

extension UIView {
    func makeCircular() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2
    }
}
