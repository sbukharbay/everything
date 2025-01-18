//
//  GradientFlashView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 17/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

@IBDesignable public class GradientFlashView: UIView {
    @IBInspectable public var topColor: UIColor = .systemRed {
        didSet {
            setupLayer()
        }
    }

    @IBInspectable public var middleColor: UIColor = .systemGreen {
        didSet {
            setupLayer()
        }
    }

    @IBInspectable public var bottomColor: UIColor = .systemBlue {
        didSet {
            setupLayer()
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    override public class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    public func set(colors: [UIColor]) {
        guard colors.count >= 3 else {
            return
        }
        topColor = colors[0]
        middleColor = colors[1]
        bottomColor = colors[2]
    }

    func setupLayer() {
        if let layer = layer as? CAGradientLayer {
            layer.colors = [topColor.cgColor, middleColor.cgColor, bottomColor.cgColor]
            layer.cornerRadius = 2.0
            layer.masksToBounds = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shouldRasterize = true

            setNeedsDisplay()
        }
    }
}
