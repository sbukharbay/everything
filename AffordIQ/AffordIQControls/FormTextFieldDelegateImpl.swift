//
//  FormTextFieldDelegateImpl.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 16/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public class FormTextFieldDelegateImpl<F: Form>: NSObject, UITextFieldDelegate {
    weak var form: F?
    var viewModel: F.ViewModelType?
    let liveValidation: Bool

    public init(form: F, viewModel: F.ViewModelType, liveValidation: Bool = false) {
        self.form = form
        self.viewModel = viewModel
        self.liveValidation = liveValidation

        super.init()

        form.fields.forEach { $0?.delegate = self }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let viewModel = viewModel,
              let form = form,
              let field = form.taggedFields[textField]
        else {
            return false
        }

        let result = viewModel.textFieldShouldReturn(field: field, messageSetters: form.messageSetters, values: form.values)

        if result {
            switch textField.returnKeyType {
            case .next:
                if let nextField = form.nextField(after: field) {
                    nextField.becomeFirstResponder()
                } else {
                    textField.resignFirstResponder()
                }
            case .done, .search:
                textField.resignFirstResponder()
                form.submit()
            default:
                textField.resignFirstResponder()
            }
        } else {
            form.updateFocus(textField: textField, for: field)
        }

        return result
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let form = form,
              let field = form.taggedFields[textField]
        else {
            return
        }

        if !form.isEditing {
            form.isEditing = true
        }
        form.updateFocus(textField: textField, for: field)
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let form = form else {
            return true
        }

        if form.isClosing {
            return true
        }

        guard let viewModel = viewModel,
              let field = form.taggedFields[textField]
        else {
            return false
        }

        let endEditing = viewModel.textFieldShouldReturn(field: field, messageSetters: form.messageSetters, values: form.values)

        if endEditing {
            textField.text = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }

        if let standardTextField = textField as? StandardTextField {
            if endEditing {
                standardTextField.focusState = .normal
            } else {
                standardTextField.focusState = .focusedError
            }
        }

        if textField.textContentType == .newPassword {
            return true
        }

        return endEditing
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let viewModel = viewModel,
              let form = form,
              let field = form.taggedFields[textField]
        else {
            return false
        }

        if let filter = form.filters[field] {
            let filtered = string.filter(filter)

            if string != filtered {
                return false
            }
        }

        var values = form.values
        let currentValue = values[field] ?? ""
        let newValue = currentValue.replacing(range: range, with: string)

        if let allowChangePredicate = form.allowChangePredicates[field],
           !allowChangePredicate.evaluate(with: newValue) {
            return false
        }

        values[field] = newValue
        form.isSubmitEnabled = viewModel.isValid(values: values)

        if viewModel.isValid(field: field, values: values) {
            form.messageSetters[field]?(nil)

            if let standardTextField = textField as? StandardTextField {
                standardTextField.focusState = .focused
            }
        } else {
            if liveValidation,
               let message = viewModel.validationMessage(field: field, values: values) {
                asyncAlways {
                    form.messageSetters[field]?(message)
                }
            }
        }

        return true
    }
}
