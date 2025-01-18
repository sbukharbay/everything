//
//  BubbleBackground.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 10/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@IBDesignable public class BubbleBackground: UIView {
    @IBOutlet var sizingView: UIView? {
        didSet {
            updateBorder()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setNeedsLayout()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setNeedsLayout()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateBorder()
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateBorder()
    }

    private func updateBorder() {
        if let sizingView = sizingView {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            layer.cornerRadius = round(sizingView.bounds.height / 2.0)
            layer.masksToBounds = true
            layer.setNeedsDisplay()
        }
    }
}
