//
//  TravelCustomTextField.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/20/25.
//

import UIKit
import SnapKit
import RxCocoa

enum InputMode {
    case numberPicker(range: ClosedRange<Int>)
    case datePicker
}

final class TravelCustomTextField: UIView {
    
    // MARK: Properties
    let didBeginEditing = PublishRelay<Void>()
    var didAttemptToEditWhilePending: (() -> Void)?
    var onTappedWhilePending: (() -> Void)?
    
    // MARK: Views
    private let fieldContainer = UIView()
    let textField = UITextField()
    private let unitLabel = UILabel()
    private let underlineView = UIView()
    private let detailLabel = UILabel()

    private var pickerView: UIPickerView?
    private var datePicker: UIDatePicker?
    private var numberList: [Int] = []

    // MARK: Properties
    private let inputMode: InputMode
    private let isStartField: Bool

    // MARK: Init
    init(unit: String = "", detail: String = "", mode: InputMode, isStartField: Bool = true) {
        self.inputMode = mode
        self.isStartField = isStartField
        super.init(frame: .zero)
        textField.delegate = self
        setUpFoundation()
        setUpHierarchy()
        setUpUI(unit: unit, detail: detail)
        setUpLayout()
        setUpInputMode()
        setUpActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpFoundation() {
        self.backgroundColor = .clear
    }

    func setUpHierarchy() {
        [
            fieldContainer,
            underlineView,
            detailLabel
        ].forEach { self.addSubview($0) }

        [
            textField,
            unitLabel
        ].forEach { fieldContainer.addSubview($0) }
    }

    func setUpUI(unit: String, detail: String) {
        textField.textAlignment = .right
        switch inputMode {
        case .numberPicker:
            unitLabel.attributedText = unit.pretendardAttributedString(style: .body3)
            detailLabel.attributedText = detail.pretendardAttributedString(style: .body3)
        case .datePicker:
            unitLabel.isHidden = true
            textField.attributedPlaceholder = isStartField ? "시작일 입력".pretendardAttributedString(style: .body3, color: .white)
                                                            : "종료일 입력".pretendardAttributedString(style: .body3, color: .white)
        }

        textField.do {
            $0.textAlignment = .right
            $0.font = .PretendardStyle.body3.font
            $0.textColor = .white
        }

        underlineView.do {
            $0.backgroundColor = .white
        }
    }
    
    func setUpLayout() {
        fieldContainer.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }

        unitLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
        }

        textField.snp.makeConstraints {
            $0.centerY.equalTo(unitLabel).offset(1)
            $0.leading.bottom.equalToSuperview()
            switch inputMode {
            case .numberPicker:
                $0.trailing.equalToSuperview().inset(15)
            case .datePicker:
                $0.trailing.equalToSuperview()
            }
        }

        underlineView.snp.makeConstraints {
            $0.top.equalTo(fieldContainer.snp.bottom).offset(2)
            $0.horizontalEdges.equalTo(fieldContainer)
            $0.height.equalTo(1)
        }

        detailLabel.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom).offset(4)
            $0.leading.equalTo(fieldContainer)
            $0.bottom.equalToSuperview()
        }
    }

    func setUpInputMode() {
        textField.inputAccessoryView = createToolBar()
        textField.textAlignment = .right
        switch inputMode {
        case .numberPicker(let range):
            numberList = Array(range)
            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            textField.inputView = picker
            pickerView = picker
        case .datePicker:
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            textField.inputView = datePicker
            self.datePicker = datePicker
        }
    }

    func setUpActions() {
        textField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusField))
        self.addGestureRecognizer(tapGesture)
    }

    @objc func focusField() {
        textField.becomeFirstResponder()
    }

    @objc func dateChanged() {
        guard let datePicker = datePicker else { return }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년  M월  d일"
        textField.text = formatter.string(from: datePicker.date)
    }
    
    private func createToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true

        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneTapped))
        done.tintColor = .orange

        toolbar.setItems([flexible, done], animated: false)
        return toolbar
    }

    @objc private func doneTapped() {
        self.endEditing(true)
    }
}

// MARK: UITextFieldDelegate
extension TravelCustomTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        underlineView.backgroundColor = .orange
        unitLabel.textColor = .orange
        didBeginEditing.accept(())
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        underlineView.backgroundColor = .white
        unitLabel.textColor = .white
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        onTappedWhilePending?()
        return true
    }
}

// MARK: UIPickerViewDelegate & DataSource
extension TravelCustomTextField: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        numberList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(numberList[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = "\(numberList[row])"
    }
}

// MARK: Public Accessors
extension TravelCustomTextField {
    var selectedText: String? { textField.text }
    var selectedDate: Date? { datePicker?.date }
    var selectedNumber: Int? {
        guard let text = textField.text, let number = Int(text) else { return nil }
        return number
    }

    func updateText(_ text: String?) {
        textField.text = text
    }
}
