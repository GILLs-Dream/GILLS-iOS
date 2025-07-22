//
//  DatePickerViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/22/25.
//

import UIKit
import RxSwift
import SnapKit

final class DatePickerViewController: UIViewController {
    enum PickerMode {
        case single // 단일 날짜
        case range // 기간 날짜
    }

    var selectedDate: Date?
    var onDateSelected: ((Date) -> Void)?
    
    private let disposeBag = DisposeBag()
    private let datePicker = UIDatePicker()
    private let confirmButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpHierarchy()
        setupUI()
        setUpLayout()
    }
    
    private func setUpHierarchy() {
        [
            datePicker,
            confirmButton,
            cancelButton
        ].forEach { self.view.addSubview($0) }
    }

    private func setupUI() {
        self.view.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }
        
        datePicker.do {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .inline
            $0.locale = Locale(identifier: "ko_KR")
        }
        
        confirmButton.do {
            $0.setTitle("완료", for: .normal)
        }
        
        cancelButton.do {
            $0.setTitle("취소", for: .normal)
        }
    }
    
    private func setUpLayout() {
        datePicker.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(50)
        }

        cancelButton.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(10)
            $0.trailing.equalTo(confirmButton.snp.leading).offset(-10)
            $0.bottom.equalToSuperview().inset(50)
        }

        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    }

    @objc private func didTapConfirm() {
        onDateSelected?(datePicker.date)
        dismiss(animated: true)
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
}
