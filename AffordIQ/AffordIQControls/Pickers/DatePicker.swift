//
//  DatePicker.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 08/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public class DatePicker: PickerBase<Date> {
    weak var pickerView: UIDatePicker?

    public let formatter: DateFormatter

    private init(pickerView: UIDatePicker?, textField: UITextField?, styles: AppStyles, selectedValue: Date?) {
        formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium

        super.init(textField: textField, selectedValue: selectedValue, styles: styles)

        pickerView?.datePickerMode = .date
        pickerView?.date = selectedValue ?? Date(timeIntervalSince1970: 0)

        pickerView?.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }

    @IBAction func valueChanged(_ sender: Any?) {
        guard let textField = textField,
              let picker = sender as? UIDatePicker
        else {
            return
        }

        let newValue = formatter.string(from: picker.date)

        let range = NSRange(location: 0, length: textField.text?.count ?? 0)
        if textField.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: newValue) ?? true {
            textField.text = newValue
            _ = textField.delegate?.textFieldShouldEndEditing?(textField)

            if let standardTextField = textField as? StandardTextField,
               standardTextField.focusState == .normal {
                standardTextField.focusState = .focused
            }
        }
    }

    public static func addPicker(to textField: UITextField?, styles: AppStyles, selectedValue: Date?) -> DatePicker? {
        let pickerView = UIDatePicker(frame: UIScreen.main.bounds)

        if #available(iOS 14, *) {
            pickerView.preferredDatePickerStyle = .wheels
            pickerView.frame = UIScreen.main.bounds
        }

        let valuePicker = DatePicker(pickerView: pickerView, textField: textField, styles: styles, selectedValue: selectedValue)
        valuePicker.configure(pickerView: pickerView)
        valuePicker.addAccessoryView(to: textField, styles: styles)
        pickerView.accessibilityIdentifier = textField?.accessibilityIdentifier

        return valuePicker
    }
}

extension DatePicker: Stylable {
    public func apply(styles: AppStyles) {
        self.styles = styles

        if let stylable = textField?.inputAccessoryView as? Stylable {
            stylable.apply(styles: styles)
        }

        if pickerView?.window != nil {
            pickerView?.setNeedsDisplay()
        }
    }
}
