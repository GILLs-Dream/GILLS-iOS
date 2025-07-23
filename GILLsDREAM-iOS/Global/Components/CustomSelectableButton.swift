//
//  CustomSelectableButton.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/23/25.
//

import UIKit

final class CustomSelectableButton: UIButton {
    // MARK: Properties
    private var title: String

    init(title: String = "선택") {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: setUpUI
    private func setupUI() {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.background.backgroundColor = .clear

        self.configuration = config
        self.setAttributedTitle(title.pretendardAttributedString(style: .body2), for: .normal)
        self.setImage(.imgCircle, for: .normal)
        self.setImage(.imgCheckedCircle, for: .selected)
        self.contentHorizontalAlignment = .left
    }

    func updateTitle(_ title: String) {
        self.title = title
        self.setTitle(title, for: .normal)
    }

    override var isSelected: Bool {
        didSet {
            self.setImage(UIImage(named: isSelected ? "img_checked_circle" : "img_circle"), for: .normal)
        }
    }
}
