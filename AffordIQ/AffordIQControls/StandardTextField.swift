//
//  StandardTextField.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 21/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@objc public enum TextFieldState: Int {
    case normal = 0
    case focused = 1
    case focusedError = 2
}

@IBDesignable public class StandardTextField: UITextField {
    @IBInspectable public var fillColor: UIColor = .init(white: 0.5, alpha: 0.3)
    @IBInspectable public var focusColor: UIColor = .init(hex: "#72F0F0")
    @IBInspectable public var errorColor: UIColor = .init(hex: "#F25A85")
    @IBInspectable public var placeholderColor: UIColor = .init(white: 1.0, alpha: 0.6)
    public var paddingLeft: CGFloat = 0

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupBorder()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBorder()
    }

    public var focusState: TextFieldState = .normal {
        didSet {
            updateState()
        }
    }

    private func setupBorder() {
        textColor = UIColor.white
        layer.borderWidth = 1.0
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        updateState()
    }

    private func updateState() {
        switch focusState {
        case .normal:
            layer.backgroundColor = fillColor.cgColor
            layer.borderColor = fillColor.cgColor
        case .focused:
            layer.backgroundColor = fillColor.cgColor
            layer.borderColor = focusColor.cgColor
        case .focusedError:
            layer.backgroundColor = fillColor.cgColor
            layer.borderColor = errorColor.cgColor
        }
    }

    override public func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        layoutIfNeeded()
        return resigned
    }

    override public var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = max(size.height, 38.0)
        return size
    }

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8.0 + paddingLeft, dy: 4.0)
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8.0 + paddingLeft, dy: 4.0)
    }

    override public func drawPlaceholder(in rect: CGRect) {
        let placeholderText = placeholder ?? ""
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: font!
        ]

        let attributedText = NSAttributedString(string: placeholderText, attributes: attributes)
        let boundingRect = attributedText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil)
        let verticalOffset = rect.size.height - boundingRect.size.height

        let drawingRect = rect.insetBy(dx: 0.0, dy: verticalOffset / 2.0).integral
        attributedText.draw(with: drawingRect, options: .usesLineFragmentOrigin, context: nil)
        updateState()
    }

    public func apply(styles: AppStyles, field: AppStyles.Field) {
        fillColor = field.fill.color
        textColor = field.text.color
        placeholderColor = field.placeholder.color
        focusColor = field.focusedBorder.color
        errorColor = field.focusedErrorBorder.color
        keyboardAppearance = .dark
        
        font = styles.fonts.sansSerif.body

        updateState()
        setNeedsDisplay()
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        if let stylable = self as? Stylable,
           let defaultStyles = InterfaceBuilderStyles.styles {
            stylable.apply(styles: defaultStyles)
        }
    }
}

@IBDesignable public class TextFieldLight: StandardTextField {}

extension TextFieldLight: Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, field: styles.colors.fields.light)
    }
}

@IBDesignable public class TextFieldDark: StandardTextField {}

extension TextFieldDark: Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, field: styles.colors.fields.dark)
    }
}
