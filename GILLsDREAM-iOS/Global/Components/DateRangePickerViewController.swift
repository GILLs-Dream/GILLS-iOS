//
//  DateRangePickerController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/22/25.
//

import UIKit
import SnapKit

final class DateRangePickerController: UIViewController {
    private enum Step {
        case startDate
        case endDate
    }

    private var step: Step = .startDate
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?

    var onDateRangeSelected: ((Date, Date) -> Void)?

    private let titleLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        updateForCurrentStep()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.clipsToBounds = true

        titleLabel.do {
            $0.font = .boldSystemFont(ofSize: 18)
            $0.textAlignment = .center
        }

        datePicker.do {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .inline
            $0.locale = Locale(identifier: "ko_KR")
        }

        nextButton.do {
            $0.setTitle("다음", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        }

        [titleLabel, datePicker, nextButton].forEach {
            view.addSubview($0)
        }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        datePicker.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        nextButton.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(50)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    private func updateForCurrentStep() {
        switch step {
        case .startDate:
            titleLabel.text = "체크인 날짜"
            nextButton.setTitle("다음", for: .normal)
        case .endDate:
            titleLabel.text = "체크아웃 날짜"
            nextButton.setTitle("완료", for: .normal)
        }
    }

    @objc private func nextButtonTapped() {
        switch step {
        case .startDate:
            selectedStartDate = datePicker.date
            datePicker.minimumDate = datePicker.date
            step = .endDate
            updateForCurrentStep()
        case .endDate:
            selectedEndDate = datePicker.date
            if let start = selectedStartDate, let end = selectedEndDate {
                onDateRangeSelected?(start, end)
                dismiss(animated: true)
            }
        }
    }
}
