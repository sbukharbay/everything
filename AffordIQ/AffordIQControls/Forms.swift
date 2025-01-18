//
//  Forms.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 28/04/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

/// A representation of a message setter for a form field.
public typealias MessageSetter = (String?) -> Void

/// Protocol for view models representing data entry forms.
public protocol FormViewModel {
    /// An enumeration representing the form fields in order.
    associatedtype FieldType: Hashable, CaseIterable

    /// Validate all values for the form.
    /// - Parameter values: the current field values from the view.
    /// - Returns: `true` if the field is valid, `false` otherwise.
    func isValid(values: [FieldType: String]) -> Bool
    /// Validate the specified field using the current values from the view.
    /// - Parameters:
    ///   - field: the field to validate
    ///   - values: the current field values from the view.
    /// - Returns: `true` if the field is valid, `false` otherwise.
    func isValid(field: FieldType, values: [FieldType: String]) -> Bool
    /// Generate a validation message for the specified field.
    /// - Parameters:
    ///   - field: the field to validate
    ///   - values: the current field values from the view.
    /// - Returns: `a message if the field is invalid, `nil` otherwise.
    func validationMessage(field: FieldType, values: [FieldType: String]) -> String?
    /// Determine whether editing should end for a field on the form.
    /// - Parameters:
    ///   - field: the field to validate
    ///   - messageSetters: the message setters from the view.
    ///   - values: the current field values from the view.
    /// - Returns: `true` if the field is valid, `false` otherwise.
    func textFieldShouldReturn(field: FieldType, messageSetters: [FieldType: MessageSetter], values: [FieldType: String]) -> Bool
    /// Submit the values for processing.
    /// - Parameters:
    ///   - values: the current field values from the view.
    func submit(values: [FieldType: String])
    /// Get an underlying value for a field from a dictionary of mappings.
    /// - Parameters:
    ///   - field: the field.
    ///   - values: the current field values from the view.
    ///   - pickerValues: a dictionary containg a mapping of display strings to field values.
    func getValue<T>(field: FieldType, values: [FieldType: String], from pickerValues: [(String, T?)]) -> T?
    /// Get a display string for a field value from a dictionary of mappings.
    /// - Parameters:
    ///   - value: the current field value.
    ///   - pickerValues: a dictionary containg a mapping of display strings to field values.
    func getText<T: Equatable>(value: T?, from pickerValues: [(String, T?)]) -> String?
}

/// Protocol for views representing data entry forms.
public protocol Form: AnyObject {
    /// The associated view model type for the form.
    associatedtype ViewModelType: FormViewModel

    /// The associated view model instance for the form.
    var viewModel: ViewModelType? { get }
    /// The fields for the form.
    var fields: [UITextField?] { get }
    /// The validation message labels for the form.
    var messages: [UILabel?] { get }
    /// Setters for the text of the validation message labels for the form.
    var messageSetters: [ViewModelType.FieldType: MessageSetter] { get }
    /// A dictionary of `fields` associated with the view model's field type.
    var taggedFields: [UITextField?: ViewModelType.FieldType] { get }
    /// A dictionary of field values, keyed by the view model's field type.
    var values: [ViewModelType.FieldType: String] { get }
    /// A dictionary of text entry filters, keyed by the view model's field type. Used to filter invalid characters from text entry.
    var filters: [ViewModelType.FieldType: (Character) -> Bool] { get }
    // A dictionary of predicates as to whether text changes should be allowed, keyed by the view model's field type.
    var allowChangePredicates: [ViewModelType.FieldType: NSPredicate] { get }

    /// The currently displayed validation messages, keyed by the view model's field type.
    var displayedMessages: [ViewModelType.FieldType: String] { get }
    /// `true` if the view is currently closing and validation should be ignored, `false` otherwise.
    var isClosing: Bool { get }

    /// `true` if the view is currently editing, `false` otherwise.
    var isEditing: Bool { get set }

    /// The status of the submit button of the view, which will be enabled and disabled depending on the overall validity of the form.
    var isSubmitEnabled: Bool { get set }

    /// Called when display of validation messages is changed.
    func formLayoutUpdated()
    /// Clear all currently displayed validation messages.
    func clearMessages()
    /// Submit the form.
    func submit()

    /// Update the focus ring etc. for the specified field.
    /// - Parameters:
    ///   - textField: the text field on the form representing the specified field.
    ///   - field: the key of the specified field.
    func updateFocus(textField: UITextField?, for field: ViewModelType.FieldType)

    /// Returns the next field to receive focus on exiting the specified field
    /// - Parameter field: The currently focused field.
    func nextField(after field: ViewModelType.FieldType) -> UITextField?
}

public extension FormViewModel {
    func isValid(values: [FieldType: String]) -> Bool {
        values.map { isValid(field: $0.key, values: values) }.allSatisfy { $0 }
    }

    func getValue<T>(field: FieldType,
                     values: [FieldType: String],
                     from pickerValues: [(String, T?)]) -> T? {
        if let fieldValue = values[field], let pickerValue = pickerValues.first(where: { $0.0 == fieldValue }) {
            return pickerValue.1
        }

        return nil
    }

    func getText<T: Equatable>(value: T?, from pickerValues: [(String, T?)]) -> String? {
        if let value = value, let pickerValue = pickerValues.first(where: { $0.1 == value }) {
            return pickerValue.0
        }

        return ""
    }

    func textFieldShouldReturn(field: FieldType,
                               messageSetters: [FieldType: MessageSetter],
                               values: [FieldType: String]) -> Bool {
        let isValid = self.isValid(field: field, values: values)
        let validationMessage = self.validationMessage(field: field, values: values)

        messageSetters[field]?(validationMessage)

        return isValid
    }
}

public extension Form where Self: UIViewController {
    var messageSetters: [ViewModelType.FieldType: MessageSetter] {
        let setters: [MessageSetter] = messages.map { label in { text in
                let hide = text?.isEmpty ?? true
                let wasHidden = label?.isHidden ?? true

                label?.text = text

                if wasHidden != hide {
                    label?.isHidden = hide
                    self.formLayoutUpdated()
                }
            }
        }

        return [ViewModelType.FieldType: MessageSetter].from(zip: zip(Array(ViewModelType.FieldType.allCases), setters))
    }

    var taggedFields: [UITextField?: ViewModelType.FieldType] {
        [UITextField?: ViewModelType.FieldType]
            .from(zip: zip(fields, Array(ViewModelType.FieldType.allCases)))
    }

    var values: [ViewModelType.FieldType: String] {
        let fieldValues = fields.map { $0?.text ?? "" }

        return [ViewModelType.FieldType: String].from(zip: zip(Array(ViewModelType.FieldType.allCases), fieldValues))
    }

    var filters: [ViewModelType.FieldType: (Character) -> Bool] {
        return [:]
    }

    var allowChangePredicates: [ViewModelType.FieldType: NSPredicate] {
        [:]
    }

    var displayedMessages: [ViewModelType.FieldType: String] {
        let messageValues = messages.map { $0?.text ?? "" }

        return [ViewModelType.FieldType: String].from(zip: zip(Array(ViewModelType.FieldType.allCases), messageValues))
    }

    func clearMessages() {
        messages.forEach {
            $0?.text = ""
            $0?.isHidden = true
        }
    }

    func submit() {
        view.isUserInteractionEnabled = false

        guard let viewModel = viewModel else { return }

        let sanitizedValues = values.compactMapValues { $0.sanitized }
        let ok = viewModel.isValid(values: sanitizedValues)

        guard ok else { return }

        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        view.endEditing(true)
        viewModel.submit(values: sanitizedValues)
    }

    func updateFocus(textField: UITextField?, for field: ViewModelType.FieldType) {
        let isValid = displayedMessages[field]?.isEmpty ?? true

        if let standardTextField = textField as? StandardTextField {
            standardTextField.focusState = isValid ? .focused : .focusedError
        }
    }

    func nextField(after field: ViewModelType.FieldType) -> UITextField? {
        return getNextField(in: self, after: field)
    }

    func formLayoutUpdated() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

public func getNextField<F: Form>(in form: F, after field: F.ViewModelType.FieldType) -> UITextField? {
    let allCases = F.ViewModelType.FieldType.allCases

    if let currentIndex = allCases.firstIndex(of: field),
       currentIndex < allCases.endIndex {
        let nextIndex = allCases.index(currentIndex, offsetBy: 1)
        let distance = allCases.distance(from: allCases.startIndex, to: nextIndex)

        guard distance < form.fields.count else {
            return nil
        }
        return form.fields[distance]
    }

    return nil
}
