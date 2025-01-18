//
//  StandardTextView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 29.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public class StandardTextView: UITextView {
    @IBInspectable public var fillColor: UIColor = .init(white: 0.5, alpha: 0.3)
    @IBInspectable public var focusColor: UIColor = .init(hex: "#72F0F0")
    @IBInspectable public var errorColor: UIColor = .init(hex: "#F25A85")
    @IBInspectable public var placeholderColor: UIColor = .init(white: 1.0, alpha: 0.6)
    public var paddingLeft: CGFloat = 0

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupBorder()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBorder()
    }

    public var focusState: TextFieldState = .normal {
        didSet {
            changeState()
        }
    }

    private func setupBorder() {
        textColor = UIColor.white
        layer.borderWidth = 0.0
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        changeState()
    }

    private func changeState() {
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

    override public var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = max(size.height, 38.0)
        return size
    }

    override public func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        layoutIfNeeded()
        return resigned
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        if let stylable = self as? Stylable,
           let defaultStyles = InterfaceBuilderStyles.styles {
            stylable.apply(styles: defaultStyles)
        }
    }

    public func apply(styles: AppStyles, field: AppStyles.Field) {
        fillColor = field.fill.color
        textColor = field.text.color
        placeholderColor = field.placeholder.color
        focusColor = field.focusedBorder.color
        errorColor = field.focusedErrorBorder.color

        font = styles.fonts.sansSerif.body

        changeState()
        setNeedsDisplay()
    }
}

@IBDesignable public class TextViewDark: StandardTextView, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, field: styles.colors.fields.dark)
    }
}

@IBDesignable public class FooterTextView: StandardTextView, Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.footnote
        textColor = styles.colors.text.fieldDark.color
    }
}

@IBDesignable public class TermsConditionTextView: StandardTextView, Stylable {
    public func apply(styles: AppStyles) {
        textColor = UIColor.white
        font = styles.fonts.sansSerif.subheadline
    }
}
