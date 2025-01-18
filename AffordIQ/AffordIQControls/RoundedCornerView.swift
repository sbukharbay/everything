//
//  RoundedCornerView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 22/01/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

@IBDesignable public class RoundedCornerView: UIView {
    @IBInspectable public var cornerRadius: CGFloat = 16.0 {
        didSet {
            setup()
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

    func maskedCorners() -> CACornerMask {
        return [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    func setup() {
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners()
        layer.masksToBounds = true
    }
}

@IBDesignable public class RoundedTopView: RoundedCornerView {
    override func maskedCorners() -> CACornerMask {
        return [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}
