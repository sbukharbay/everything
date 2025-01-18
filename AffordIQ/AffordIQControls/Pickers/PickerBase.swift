//
//  PickerBase.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 11/01/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public class PickerBase<T: Equatable>: NSObject {
    weak var textField: UITextField?
    var selectedValue: T?
    var styles: AppStyles

    internal init(textField: UITextField? = nil, selectedValue: T? = nil, styles: AppStyles) {
        self.textField = textField
        self.selectedValue = selectedValue
        self.styles = styles
    }

    // TODO: Reinstate this once the layout problems with Xcode 12.5 are resolved
    let useBlurEffect = false

    func configure(pickerView: UIView) {
        pickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if useBlurEffect {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            let backgroundView = UIVisualEffectView(effect: blurEffect)
            backgroundView.frame = UIScreen.main.bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundView.contentView.addSubview(pickerView)
            textField?.inputView = backgroundView
        } else {
            textField?.inputView = pickerView
        }
    }

    var uiKitBundle: Bundle {
        return Bundle(for: UITextField.self)
    }

    func addAccessoryView(to textField: UITextField?, styles: AppStyles) {
        var frame = UIScreen.main.bounds
        frame.size.height = 44.0

        let toolbar = UIToolbar(frame: frame)
        toolbar.barStyle = .black
        toolbar.isTranslucent = true

        var doneButton: UIBarButtonItem!

        if let textField = textField {
            switch textField.returnKeyType {
            case .next:
                doneButton = UIBarButtonItem(title: NSLocalizedString("Next", bundle: uiKitBundle, comment: "Next (System)"), style: .plain, target: self, action: #selector(done(_:)))

            case .search:
                doneButton = UIBarButtonItem(title: NSLocalizedString("Search", bundle: uiKitBundle, comment: "Search (System)"), style: .plain, target: self, action: #selector(done(_:)))

            default:
                doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
            }
        }

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let clearButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear(_:)))

        toolbar.items = [clearButton, space, doneButton]

        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        toolbar.apply(styles: styles)

        textField?.inputAccessoryView = toolbar
    }

    @objc func done(_: Any?) {
        if let textField = textField {
            _ = textField.delegate?.textFieldShouldReturn?(textField)
        }
    }

    @objc func clear(_: Any?) {
        textField?.text = ""
        textField?.endEditing(true)
    }
}
