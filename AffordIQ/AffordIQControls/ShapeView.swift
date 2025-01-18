//
//  ShapeView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 21/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class ShapeView: UIView {
    weak var shapeLayer: CAShapeLayer?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    func setupLayers() {
        let newShapeLayer = CAShapeLayer()
        let bounds = layer.bounds

        newShapeLayer.fillColor = UIColor.white.cgColor
        newShapeLayer.strokeColor = UIColor.white.cgColor
        newShapeLayer.path = path(for: bounds)
        newShapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newShapeLayer.bounds = bounds
        newShapeLayer.position = bounds.center

        shapeLayer = newShapeLayer
        layer.mask = newShapeLayer
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        if layer == self.layer {
            let bounds = layer.bounds.integral.insetBy(dx: 1.0, dy: 1.0)

            if let shapeLayer = shapeLayer,
               shapeLayer.bounds != bounds {
                shapeLayer.bounds = bounds
                shapeLayer.position = layer.bounds.center
                shapeLayer.path = path(for: bounds)
                shapeLayer.rasterizationScale = UIScreen.main.scale
                shapeLayer.shouldRasterize = true
            }
        }
    }

    func path(for _: CGRect) -> CGMutablePath {
        return CGMutablePath()
    }
}

@IBDesignable public class CircleView: ShapeView {
    override func path(for bounds: CGRect) -> CGMutablePath {
        let path = super.path(for: bounds)
        path.addEllipse(in: bounds)
        return path
    }
}

@IBDesignable public class RoundedBottomView: ShapeView {
    @IBInspectable public var radius: CGFloat = 16.0 {
        didSet {
            layer.setNeedsLayout()
        }
    }

    override func path(for bounds: CGRect) -> CGMutablePath {
        let result = super.path(for: bounds)
        let rect = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
        result.addPath(rect.cgPath)
        return result
    }
}
