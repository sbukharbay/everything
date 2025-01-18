//
//  ContentFittingTableView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 11/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

@IBDesignable public class ContentFittingTableView: UITableView {
    @IBInspectable public var fitToContent: Bool = true {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    var minimumHeight: CGFloat = 0.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override public var contentSize: CGSize {
        didSet {
            if fitToContent {
                invalidateIntrinsicContentSize()
            }
        }
    }

    override public var intrinsicContentSize: CGSize {
        if !fitToContent {
            return super.intrinsicContentSize
        }

        layoutIfNeeded()

        return CGSize(width: UIView.noIntrinsicMetric, height: max(contentSize.height, minimumHeight))
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        invalidateIntrinsicContentSize()

        if let defaultStyles = InterfaceBuilderStyles.styles {
            style(styles: defaultStyles)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if fitToContent {
            isScrollEnabled = contentSize.height > bounds.size.height
        }
    }
}
