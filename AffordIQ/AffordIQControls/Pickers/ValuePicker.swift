//
//  ValuePicker.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 01/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public class ValuePicker<T: Equatable>: PickerBase<T>, UIPickerViewDataSource, UIPickerViewDelegate {
    weak var pickerView: UIPickerView?
    let values: [(String, T?)]

    private init(pickerView: UIPickerView?, textField: UITextField?, values: [(String, T?)], styles: AppStyles, selectedValue: T?) {
        self.pickerView = pickerView
        self.values = values

        super.init(textField: textField, selectedValue: selectedValue, styles: styles)

        pickerView?.delegate = self
        pickerView?.dataSource = self

        if let selectedValue = selectedValue,
           let row = values.firstIndex(where: { _, value -> Bool in

               value == selectedValue
           }) {
            pickerView?.selectRow(row, inComponent: 0, animated: false)
        } else {
            pickerView?.selectRow(0, inComponent: 0, animated: false)
        }
    }

    public static func addPicker(to textField: UITextField?, values: [(String, T?)], styles: AppStyles, selectedValue: T?) -> ValuePicker? {
        guard let textField = textField else {
            return nil
        }

        let pickerView = UIPickerView(frame: UIScreen.main.bounds)
        let valuePicker = ValuePicker(pickerView: pickerView, textField: textField, values: values, styles: styles, selectedValue: selectedValue)
        valuePicker.configure(pickerView: pickerView)

        valuePicker.addAccessoryView(to: textField, styles: styles)

        pickerView.accessibilityIdentifier = textField.accessibilityIdentifier

        return valuePicker
    }

    @objc override func clear(_ sender: Any?) {
        pickerView?.selectRow(0, inComponent: 0, animated: true)

        super.clear(sender)
    }

    public func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return values.count
    }

    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
        let isSelected = pickerView.selectedRow(inComponent: 0) == row
        let attributes: [NSAttributedString.Key: Any] = [
            .font: isSelected ? styles.fonts.sansSerif.headline : styles.fonts.sansSerif.subheadline,
            .foregroundColor: styles.colors.text.fieldDark.color
        ]
        return NSAttributedString(string: values[row].0, attributes: attributes)
    }

    public func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedValue = values[row].1
        let newValue = (selectedValue == nil) ? "" : values[row].0

        if let textField = textField {
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
    }
}

extension ValuePicker: Stylable {
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
