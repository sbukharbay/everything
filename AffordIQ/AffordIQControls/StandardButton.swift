//
//  StandardButton.swift
//  AffordIQ
//
//  Created by Sultangazy Bukharbay on 20/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@objc public enum RoundedButtonStyle: Int {
    case primary = 0
    case secondary = 1
    case empty = 2
}

public extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

let defaultFill = UIColor(hex: "#72F0F0")
let defaultDisabledFill = UIColor(hex: "#99A0AA")

class BackgroundLayer: CALayer {
    weak var background: CALayer?

    override init(layer: Any) {
        let newBackground = CALayer()
        background = newBackground
        newBackground.needsDisplayOnBoundsChange = true

        super.init(layer: layer)

        needsDisplayOnBoundsChange = true
        masksToBounds = true

        addSublayer(newBackground)
    }

    override init() {
        let newBackground = CALayer()
        background = newBackground
        newBackground.needsDisplayOnBoundsChange = true

        super.init()

        needsDisplayOnBoundsChange = true
        masksToBounds = true

        addSublayer(newBackground)
    }

    required init?(coder: NSCoder) {
        let backgroundLayer = CALayer()
        background = backgroundLayer
        backgroundLayer.needsDisplayOnBoundsChange = true

        super.init(coder: coder)

        needsDisplayOnBoundsChange = true
        masksToBounds = true

        addSublayer(backgroundLayer)
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        if let internalBackground = background {
            internalBackground.bounds = bounds.insetBy(dx: 0.0, dy: 4.0).integral
            internalBackground.position = bounds.center
        }
    }
}

@IBDesignable public class StandardButton: UIButton {
    override public static var layerClass: AnyClass {
        return BackgroundLayer.self
    }

    @IBInspectable public var roundedLeftCorners: Bool = true {
        didSet {
            updateStyle()
        }
    }

    @IBInspectable public var roundedRightCorners: Bool = true {
        didSet {
            updateStyle()
        }
    }

    public var fillColor: UIColor = defaultFill
    public var borderColor: UIColor = defaultFill
    public var disabledFillColor: UIColor = defaultDisabledFill
    public var disabledBorderColor: UIColor = defaultDisabledFill
    public var highlightedFillColor: UIColor = defaultFill
    public var highlightedBorderColor: UIColor = defaultFill

    public var textColor: UIColor = .black {
        didSet {
            setTitleColor(textColor, for: .normal)
        }
    }

    public var disabledTextColor: UIColor = .white {
        didSet {
            setTitleColor(disabledTextColor, for: .disabled)
        }
    }

    public var highlightTextColor: UIColor = .black {
        didSet {
            setTitleColor(highlightTextColor, for: .highlighted)
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        updateStyle()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateStyle()
    }

    override public var isEnabled: Bool {
        didSet {
            updateStyle()
        }
    }

    override public var isHighlighted: Bool {
        didSet {
            updateStyle()
        }
    }

    override public var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += 24.0
        size.height = max(size.height, 48.0)
        return size
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        invalidateIntrinsicContentSize()

        if let stylable = self as? Stylable,
           let defaultStyles = InterfaceBuilderStyles.styles {
            stylable.apply(styles: defaultStyles)
        }
        updateStyle()
    }

    private func corners() -> CACornerMask {
        switch (roundedLeftCorners, roundedRightCorners) {
        case (true, false):
            return [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMinXMaxYCorner]

        case (false, true):
            return [CACornerMask.layerMaxXMinYCorner, CACornerMask.layerMaxXMaxYCorner]

        case (false, false):
            return []

        default:
            return [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMinXMaxYCorner,
                    CACornerMask.layerMaxXMinYCorner, CACornerMask.layerMaxXMaxYCorner]
        }
    }

    fileprivate func updateStyle() {
        if buttonType != .custom {
            debugPrint("⚠️ Button \"\(title(for: .normal) ?? "(No title)")\" \(self) is not set to button type custom in the storyboard - hilarity may ensue.")
        }

        clipsToBounds = true
        tintColor = textColor
        setTitleColor(textColor, for: .normal)
        setTitleColor(disabledTextColor, for: .disabled)
        setTitleColor(highlightTextColor, for: .highlighted)

        let corners = self.corners()

        if let layer = (layer as? BackgroundLayer)?.background {
            layer.maskedCorners = corners
            // layer.cornerRadius = (roundedLeftCorners && roundedRightCorners) ? 8.0 : 4.0
            layer.cornerRadius = 8.0
            layer.borderWidth = 2.0
            layer.masksToBounds = true

            if isEnabled {
                if isHighlighted {
                    layer.backgroundColor = highlightedFillColor.cgColor
                    layer.borderColor = highlightedBorderColor.cgColor
                } else {
                    layer.backgroundColor = fillColor.cgColor
                    layer.borderColor = borderColor.cgColor
                }
            } else {
                layer.backgroundColor = disabledFillColor.cgColor
                layer.borderColor = disabledBorderColor.cgColor
            }
        }
    }

    fileprivate func apply(styles: AppStyles, buttonStyle: AppStyles.Button) {
        titleLabel?.font = styles.fonts.sansSerif.headline
        titleLabel?.adjustsFontSizeToFitWidth = true

        textColor = buttonStyle.text.color
        disabledTextColor = buttonStyle.disabledText.color
        highlightTextColor = buttonStyle.highlightedText.color
        fillColor = buttonStyle.fill.color
        borderColor = buttonStyle.border.color
        disabledBorderColor = buttonStyle.disabledBorder.color
        disabledFillColor = buttonStyle.disabledFill.color
        highlightedFillColor = buttonStyle.highlightedFill.color
        highlightedBorderColor = buttonStyle.highlightedBorder.color

        updateStyle()
    }
}

@IBDesignable public class WarningButtonDark: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.warningDark)
    }
}

@IBDesignable public class PrimaryButtonDark: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.primaryDark)
    }
}

@IBDesignable public class DarkBlueButton: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.darkBlue)
    }
}

@IBDesignable public class SecondaryButtonDark: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.secondaryDark)
    }
}

@IBDesignable public class PrimaryButtonLight: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.primaryLight)
    }
}

@IBDesignable public class SecondaryButtonLight: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.secondaryLight)
    }
}

@IBDesignable public class InlineButtonLight: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.inlineLight)
    }
}

@IBDesignable public class InlineButtonDark: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.inlineDark)
    }
}

@IBDesignable public class InlineButtonWhite: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.inlineWhite)
    }
}

@IBDesignable public class ClearButtonDarkTeal: StandardButton, Stylable {
    public func apply(styles: AppStyles) {
        super.apply(styles: styles, buttonStyle: styles.colors.buttons.clearDarkTeal)
        titleLabel?.font = styles.fonts.sansSerif.largeTitle
        titleLabel?.textAlignment = .center
    }
}
