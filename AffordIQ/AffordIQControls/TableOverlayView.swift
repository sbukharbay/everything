//
//  TableOverlayView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 11/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@objc public protocol TableOverlayViewDelegate: AnyObject {
    func overlay(_ overlay: TableOverlayView, isOpen: Bool)
}

@IBDesignable public class TableOverlayView: UIView {
    @IBOutlet private var tabContainer: UIView?
    @IBOutlet private var headingContainer: UIView?
    @IBOutlet private var titleContainer: UIView?

    @IBOutlet private var tab: UIView?
    @IBOutlet private var borderView: UIView?
    @IBOutlet private var headingLabel: UILabel?
    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet private var contentView: ContentFittingTableView?

    @IBOutlet public weak var delegate: TableOverlayViewDelegate?

    @IBInspectable public var fitToContent: Bool {
        get {
            return contentView?.fitToContent ?? false
        }
        set {
            contentView?.fitToContent = newValue
        }
    }

    @IBInspectable public var tabVisible: Bool = true {
        didSet {
            tabContainer?.isHidden = !tabVisible
            setNeedsLayout()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public var tableView: UITableView? {
        return contentView
    }

    public var heading: NSAttributedString? {
        get {
            return headingLabel?.attributedText
        }
        set {
            headingLabel?.attributedText = newValue
            headingContainer?.isHidden = newValue == nil
        }
    }

    public var title: NSAttributedString? {
        get {
            return titleLabel?.attributedText
        }
        set {
            titleLabel?.attributedText = newValue
            titleContainer?.isHidden = newValue == nil
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let nib = UINib(nibName: "TableOverlayView", bundle: Bundle(for: TableOverlayView.self))
        let nibObjects = nib.instantiate(withOwner: self, options: [:])

        if let view = nibObjects.first(where: { $0 is UIView }) as? UIView {
            view.frame = bounds
            addSubview(view)
            view.pinToSuperview()

            if let borderLayer = borderView?.layer {
                borderLayer.cornerRadius = 32.0
                borderLayer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
                borderLayer.masksToBounds = true
            }

            if let tabLayer = tab?.layer {
                tabLayer.cornerRadius = 2.0
                tabLayer.masksToBounds = true
            }

            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    public func open() {
        if fitToContent {
            fitToContent = false
            delegate?.overlay(self, isOpen: true)
        }
    }

    public func close() {
        if !fitToContent {
            fitToContent = true
            delegate?.overlay(self, isOpen: false)
        }
    }

    @IBAction func swipe(_ sender: Any?) {
        if let recognizer = sender as? UISwipeGestureRecognizer {
            switch recognizer.direction {
            case .up:
                open()

            case .down:
                close()

            default:
                break
            }
        }
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        contentView?.minimumHeight = 176.0
        invalidateIntrinsicContentSize()

        if let defaultStyles = InterfaceBuilderStyles.styles {
            headingLabel?.font = defaultStyles.fonts.sansSerif.subheadline
            titleLabel?.font = defaultStyles.fonts.sansSerif.subheadline
            titleLabel?.textColor = defaultStyles.colors.cells.overlay.detail.color
            headingLabel?.textColor = defaultStyles.colors.cells.overlay.detail.color

            style(styles: defaultStyles)
        }
    }
}
