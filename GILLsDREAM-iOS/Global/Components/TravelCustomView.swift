//
//  TravelCustomView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/20/25.
//

import UIKit
import SnapKit

final class TravelCustomView: UIView {

    // MARK: Views
    private let titleLabel = UILabel()
    let startField: TravelCustomTextField
    let endField: TravelCustomTextField?
    private let waveLabel = UILabel()

    // MARK: Init
    init(title: String, inputMode: InputMode, unit: String = "", detail: String = "") {
        self.titleLabel.attributedText = title.pretendardAttributedString(style: .body2, color: .white)
        self.startField = TravelCustomTextField(
            unit: unit,
            detail: detail,
            mode: inputMode
        )
        if case .datePicker = inputMode {
            self.endField = TravelCustomTextField(
                mode: .datePicker,
                isStartField: false
            )
        } else {
            self.endField = nil
        }

        super.init(frame: .zero)
        setUpFoundation()
        setUpHierarchy()
        setUpUI()
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TravelCustomView {
    func setUpFoundation() {
        backgroundColor = .clear
    }

    func setUpHierarchy() {
        [
            titleLabel,
            startField
        ].forEach { self.addSubview($0) }
        
        guard let endField = endField else { return }
        
        [
            endField,
            waveLabel
        ].forEach { self.addSubview($0) }
    }

    func setUpUI() {
        waveLabel.do {
            $0.attributedText = "~".pretendardAttributedString(style: .body3, color: .white)
            $0.isHidden = (endField == nil)
        }
    }

    func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        startField.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(30)
            $0.width.equalTo(182)
        }

        if let endField = endField {
            endField.snp.makeConstraints {
                $0.top.equalTo(startField.snp.bottom).offset(20)
                $0.horizontalEdges.equalTo(startField)
                $0.bottom.equalToSuperview()
            }
            
            waveLabel.snp.makeConstraints {
                $0.centerY.equalTo(endField)
                $0.trailing.equalTo(endField.snp.leading).offset(-10)
            }
        } else {
            startField.snp.makeConstraints {
                $0.bottom.equalToSuperview()
            }
        }
    }
}
