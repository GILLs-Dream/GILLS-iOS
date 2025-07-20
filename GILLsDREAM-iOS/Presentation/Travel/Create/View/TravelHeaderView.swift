//
//  TravelHeaderView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/16/25.
//

import UIKit
import SnapKit

final class TravelHeaderView: UIView {

    // MARK: Properties
    private let titles = ["얼마나?", "누구와?", "어디로?", "어떻게?"]
    private var stepViews: [UIView] = []

    var currentStep: Int = 0 {
        didSet { updateStepUI() }
    }

    // MARK: Views
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: Init
    init(titleText: String) {
        super.init(frame: .zero)
        setUpFoundation()
        setUpHierarchy()
        setUpUI(titleText: titleText)
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: SetupFunctions
    private func setUpFoundation() {
        backgroundColor = .clear
    }

    private func setUpHierarchy() {
        [
            titleLabel,
            stackView
        ].forEach { self.addSubview($0) }
        
        titles.forEach { title in
            let view = createStepView(title: title)
            stepViews.append(view)
            stackView.addArrangedSubview(view)
        }
    }

    private func setUpUI(titleText: String) {
        titleLabel.do {
            $0.numberOfLines = 3
            $0.attributedText = titleText.pretendardAttributedString(style: .title1)
            $0.textAlignment = .left
        }

        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fillEqually
            $0.alignment = .fill
        }
    }

    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.bottom.equalToSuperview()
            $0.height.equalTo(28)
            $0.width.equalTo(272)
        }
    }

    private func createStepView(title: String) -> UIView {
        let container = UIView().then {
            $0.layer.cornerRadius = 14
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
        }

        let label = UILabel().then {
            $0.attributedText = title.pretendardAttributedString(style: .body1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        container.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        return container
    }

    private func updateStepUI() {
        for (index, view) in stepViews.enumerated() {
            let isSelected = (index == currentStep)
            view.backgroundColor = isSelected ? .white : .clear
            if let label = view.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.textColor = isSelected ? .black : .white
            }
        }
    }
}
