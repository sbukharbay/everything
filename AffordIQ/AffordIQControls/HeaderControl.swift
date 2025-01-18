//
//  HeaderControl.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 21/01/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@objc public protocol HeaderControlDelegate: AnyObject {
    func headerControl(_ control: HeaderControl, didSelectButtonAtIndex index: Int)
}

@IBDesignable public class HeaderControl: UIStackView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        distribution = .equalSpacing

        update(headings: headings)
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        axis = .horizontal
        distribution = .equalSpacing

        update(headings: headings)
    }

    var styles: AppStyles?

    @IBInspectable public var tabbedAppearance: Bool = false {
        didSet {
            distribution = tabbedAppearance ? .fillEqually : .equalSpacing
            setNeedsLayout()
        }
    }

    @IBInspectable public var headings: String = "Item 1\nItem 2\nItem3" {
        didSet {
            update(headings: headings)
        }
    }

    @IBInspectable public var selectedEntry: Int = 0 {
        didSet {
            select(entryAtIndex: selectedEntry)
        }
    }

    @IBOutlet weak var delegate: HeaderControlDelegate?

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        invalidateIntrinsicContentSize()

        if let defaultStyles = InterfaceBuilderStyles.styles {
            styles = defaultStyles
            apply(styles: defaultStyles)
        }
    }

    func update(headings: String) {
        let headingEntries = headings
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        set(headingEntries: headingEntries.isEmpty ? [""] : headingEntries)
    }

    func set(headingEntries: [String]) {
        arrangedSubviews.forEach { removeArrangedSubview($0) }
        subviews.forEach { $0.removeFromSuperview() }

        var index = 0
        headingEntries.forEach {
            addArrangedSubview(headerElement(entry: $0, index: index))
            index += 1
        }
    }

    func headerElement(entry: String, index: Int) -> HeaderElement {
        let element = HeaderElement(frame: bounds)
        element.button?.setTitle(entry, for: .normal)
        element.index = index
        element.isSelected = index == selectedEntry
        element.headerControl = self

        return element
    }

    func didSelectElement(_ sender: HeaderElement) {
        if tabbedAppearance,
           let index = subviews.firstIndex(of: sender) {
            delegate?.headerControl(self, didSelectButtonAtIndex: index)
            select(entryAtIndex: index)
        }
    }

    func select(entryAtIndex: Int) {
        arrangedSubviews.compactMap { $0 as? HeaderElement }.forEach {
            $0.isSelected = $0.index == entryAtIndex

            if let styles = styles {
                $0.apply(styles: styles)
            }
        }
    }
}

extension HeaderControl: Stylable {
    public func apply(styles: AppStyles) {
        self.styles = styles

        for view in arrangedSubviews.compactMap({ $0 as? Stylable }) {
            view.apply(styles: styles)
        }
    }
}

public class HeaderElement: UIView {
    weak var button: UIButton?
    weak var highlight: CALayer?
    weak var headerControl: HeaderControl?

    var isSelected: Bool = false
    var index: Int = 0

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setup(bounds: bounds)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup(bounds: bounds)
    }

    @IBAction func didSelectElement(_: Any) {
        headerControl?.didSelectElement(self)
    }

    func setup(bounds _: CGRect) {
        let newButton = UIButton(type: .custom)
        newButton.backgroundColor = UIColor.clear
        newButton.addTarget(self, action: #selector(didSelectElement(_:)), for: .touchUpInside)
        button = newButton
        addSubview(newButton)
        newButton.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        newButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        newButton.pinToSuperview()

        let newHighlight = CALayer()
        newHighlight.backgroundColor = UIColor.cyan.cgColor
        layer.addSublayer(newHighlight)
        highlight = newHighlight
        position(highlight: newHighlight)
        setNeedsLayout()
    }

    func position(highlight: CALayer) {
        let height: CGFloat = 4.0

        var highlightFrame = layer.bounds
        highlightFrame.origin.y += highlightFrame.height - height
        highlightFrame.size.height = 3.0
        highlight.bounds = highlightFrame.integral
        highlight.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        highlight.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.maxY - height / 2.0)
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        if layer == self.layer,
           let highlight = highlight {
            position(highlight: highlight)
        }
    }
}

extension HeaderElement: Stylable {
    public func apply(styles: AppStyles) {
        if let button = button {
            let tabbedAppearance = headerControl?.tabbedAppearance ?? false

            if tabbedAppearance {
                button.titleLabel?.font = styles.fonts.sansSerif.headline
                let titleColor = isSelected ? styles.colors.text.fieldLight.color : styles.colors.text.info.color
                button.setTitleColor(titleColor, for: .normal)
                let fillColor = isSelected ? UIColor.white : UIColor(white: 0.95, alpha: 1.0)
                button.backgroundColor = fillColor
                highlight?.backgroundColor = !isSelected ? UIColor(white: 0.93, alpha: 1.0).cgColor : UIColor.clear.cgColor
            } else {
                button.titleLabel?.font = styles.fonts.sansSerif.headline
                let titleColor = isSelected ? styles.colors.buttons.primaryDark.fill.color : styles.colors.buttons.primaryDark.disabledFill.color
                button.setTitleColor(titleColor, for: .normal)
                highlight?.backgroundColor = isSelected ? styles.colors.buttons.primaryDark.fill.color.cgColor : UIColor.clear.cgColor
            }
        }
    }
}
