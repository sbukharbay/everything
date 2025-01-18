//
//  InfoOverlayView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 05/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@objc public protocol InfoOverlayDelegate {
    func performAction(infoOverlay: InfoOverlayView?)
}

@IBDesignable public class InfoOverlayView: UIView {
    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var content: UILabel?
    @IBOutlet private var action: PrimaryButtonDark?
    @IBOutlet private var borderView: UIView?

    @IBOutlet public weak var delegate: InfoOverlayDelegate?

    var styles: AppStyles?

    @IBInspectable var title: String? = "" {
        didSet {
            updateContent()
        }
    }

    @IBInspectable var body: String? = "Body text." {
        didSet {
            updateContent()
        }
    }

    @IBInspectable var image: UIImage? {
        get {
            return imageView?.image
        }
        set {
            imageView?.image = newValue
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable var showImage: Bool = true {
        didSet {
            imageView?.isHidden = !showImage
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable var actionTitle: String? {
        get {
            return action?.title(for: .normal)
        }
        set {
            action?.setTitle(newValue, for: .normal)
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable var showAction: Bool = true {
        didSet {
            action?.isHidden = !showAction
            invalidateIntrinsicContentSize()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        invalidateIntrinsicContentSize()

        if let defaultStyles = InterfaceBuilderStyles.styles {
            apply(styles: defaultStyles)
        }
    }

    private func setup() {
        let nib = UINib(nibName: "InfoOverlayView", bundle: Bundle(for: InfoOverlayView.self))
        let nibObjects = nib.instantiate(withOwner: self, options: [:])

        if let view = nibObjects.first(where: { $0 is UIView }) as? UIView {
            view.frame = bounds
            addSubview(view)
            view.pinToSuperview()

            if let borderLayer = borderView?.layer {
                borderLayer.cornerRadius = 16.0
                borderLayer.maskedCorners = [CACornerMask.layerMinXMaxYCorner, CACornerMask.layerMaxXMaxYCorner]
                borderLayer.masksToBounds = true
            }

            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    private func updateContent() {
        let text = NSMutableAttributedString()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 12.0

        let titleFont = styles?.fonts.sansSerif.headline ?? UIFont.preferredFont(forTextStyle: .headline)
        let bodyFont = styles?.fonts.sansSerif.body ?? UIFont.preferredFont(forTextStyle: .body)

        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont,
                                                              .paragraphStyle: paragraphStyle]
        let bodyAttributes: [NSAttributedString.Key: Any] = [.font: bodyFont,
                                                             .paragraphStyle: paragraphStyle]

        var addParagraphBreak = false

        if let title = title, !title.isEmpty {
            text.append(title, attributes: titleAttributes)
            addParagraphBreak = true
        }

        if let body = body, !body.isEmpty {
            if addParagraphBreak {
                text.append(String.paragraphBreak, attributes: titleAttributes)
            }

            text.append(self.body ?? "", attributes: bodyAttributes)
        }

        content?.attributedText = text
        invalidateIntrinsicContentSize()
    }

    @IBAction func buttonAction(_: Any) {
        delegate?.performAction(infoOverlay: self)
    }
}

extension InfoOverlayView: Stylable {
    public func apply(styles: AppStyles) {
        self.styles = styles
        action?.apply(styles: styles)
        updateContent()
    }
}
