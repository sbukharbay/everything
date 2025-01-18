//
//  CircularMeterView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 18/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public extension CGFloat {
    static var piOverTwo: CGFloat {
        return pi / 2.0
    }

    static var twoPi: CGFloat {
        return pi * 2.0
    }
}

@IBDesignable public class CircularMeterView: UIView {
    private weak var progressAnimation: CAAnimation?
    private weak var gradientLayer: CAGradientLayer?

    private weak var arcLayer: CAShapeLayer?
    private weak var trackLayer: CALayer?
    private weak var pieLayer: CAShapeLayer?

    @IBInspectable public var progress: Float = 1.0 {
        didSet {
            pieLayer?.path = piePath(for: bounds, progress: progress)
        }
    }

    @IBInspectable public var isClockwise: Bool = false {
        didSet {
            if isClockwise {
                layer.sublayerTransform = CATransform3DScale(CATransform3DIdentity, -1, 1, 1)
            } else {
                layer.sublayerTransform = CATransform3DIdentity
            }
        }
    }

    @IBInspectable public var numberOfSegments: Int = 16 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable public var inset: CGFloat = 2.0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable public var lineWidth: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }

    private func colorsUpdated() {
        gradientLayer?.colors = [color1, color2, color3, color4].map { $0.cgColor }
        trackLayer?.backgroundColor = trackColor.cgColor
    }

    @IBInspectable public var color1: UIColor = .init(hex: "30f2fc") {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var color2: UIColor = .init(hex: "2ec7ce") {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var color3: UIColor = .init(hex: "028e8e") {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var color4: UIColor = .init(hex: "014766") {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var trackColor: UIColor = UIColor.black.withAlphaComponent(0.2) {
        didSet {
            colorsUpdated()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setupLayers()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupLayers()
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsLayout()
        gradientLayer?.setNeedsDisplay()
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        if layer == self.layer {
            let bounds = layer.bounds.insetBy(dx: inset, dy: inset).integral
            let center = bounds.center

            var modified = false

            arcLayer?.lineWidth = lineWidth

            [arcLayer, gradientLayer, trackLayer].compactMap { $0 }.forEach { layer in

                if layer.bounds != bounds || layer.position != center {
                    layer.bounds = bounds
                    layer.position = center

                    modified = true
                }
            }

            if modified,
               let arcLayer = arcLayer,
               let pieLayer = pieLayer {
                arcLayer.path = arcPath(for: bounds, lineWidth: arcLayer.lineWidth)
                pieLayer.path = piePath(for: bounds, progress: progress)
            }
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension CircularMeterView {
    private static func position(in bounds: CGRect, layer: CALayer) {
        let center = bounds.center
        layer.bounds = bounds
        layer.position = center
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.rasterizationScale = UIScreen.main.scale
    }

    private func setupLayers() {
        var bounds = layer.bounds.isEmpty ? CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0) : layer.bounds
        bounds = bounds.insetBy(dx: inset, dy: inset).integral

        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath(for: bounds, lineWidth: lineWidth)
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = UIColor.white.cgColor
        arcLayer.lineWidth = lineWidth
        CircularMeterView.position(in: bounds, layer: arcLayer)
        self.arcLayer = arcLayer

        let trackLayer = CALayer()
        trackLayer.backgroundColor = trackColor.cgColor
        CircularMeterView.position(in: bounds, layer: trackLayer)
        self.trackLayer = trackLayer
        layer.addSublayer(trackLayer)

        let pieLayer = CAShapeLayer()
        pieLayer.path = piePath(for: bounds, progress: 1.0)
        pieLayer.fillColor = UIColor.white.cgColor
        pieLayer.strokeColor = UIColor.white.cgColor
        CircularMeterView.position(in: bounds, layer: layer)
        self.pieLayer = pieLayer

        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.colors = [color1, color2, color3, color4].map { $0.cgColor }
        gradientLayer.mask = pieLayer
        CircularMeterView.position(in: bounds, layer: layer)
        self.gradientLayer = gradientLayer
        layer.addSublayer(gradientLayer)

        layer.mask = arcLayer
    }

    private func arcPath(for bounds: CGRect, lineWidth: CGFloat) -> CGPath {
        let numberOfSegments = max(self.numberOfSegments, 1)

        let bounds = bounds.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0).integral
        let center = bounds.center
        let path = CGMutablePath()
        let increment = CGFloat.twoPi / CGFloat(numberOfSegments)
        let offset = increment * 0.1
        var startAngle = -CGFloat.piOverTwo + offset / 2.0
        let radius = bounds.size.width / 2.0

        for _ in 0 ..< numberOfSegments {
            let endAngle = startAngle + increment
            let offsetStart = startAngle + CGFloat.piOverTwo
            let startPoint = CGPoint(x: center.x + radius * sin(offsetStart),
                                     y: center.y - radius * cos(offsetStart))
            path.move(to: startPoint)
            path.addArc(center: bounds.center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle - offset,
                        clockwise: false)
            startAngle = endAngle
        }

        return path
    }

    private func piePath(for bounds: CGRect, progress: Float) -> CGPath {
        let progress = max(min(progress, 1.0), 0.0)

        let path = CGMutablePath()

        let center = bounds.center
        path.move(to: center)
        let radius = max(bounds.size.width, bounds.size.height) / 2.0
        let startAngle = -CGFloat.piOverTwo
        let endAngle = startAngle + -(CGFloat(progress) * CGFloat.twoPi)
        path.closeSubpath()
        path.addArc(center: center, radius: radius, startAngle: -CGFloat.piOverTwo, endAngle: endAngle, clockwise: true)

        return path
    }
}
