//
//  BubbleLabel.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 04/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@IBDesignable public class BubbleLabel: UIView, Stylable {
    weak var backgroundLayer: CAShapeLayer?
    weak var label: UILabel?

    @IBInspectable public var text: String? {
        get {
            return label?.text
        }
        set {
            label?.text = newValue
            invalidateIntrinsicContentSize()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackgroundView()
    }

    func setupBackgroundView() {
        let newBackgroundLayer = CAShapeLayer()
        newBackgroundLayer.frame = bounds
        newBackgroundLayer.strokeColor = UIColor.systemBlue.cgColor
        newBackgroundLayer.fillColor = newBackgroundLayer.strokeColor
        newBackgroundLayer.rasterizationScale = UIScreen.main.scale
        newBackgroundLayer.shouldRasterize = true
        layer.insertSublayer(newBackgroundLayer, at: 0)

        backgroundLayer = newBackgroundLayer
        setNeedsLayout()

        let newLabel = UILabel(frame: bounds)
        newLabel.textColor = UIColor.white
        newLabel.textAlignment = .center
        newLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(newLabel)
        label = newLabel
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        invalidateIntrinsicContentSize()

        if let defaultStyles = InterfaceBuilderStyles.styles {
            apply(styles: defaultStyles)
        }
    }

    override public var intrinsicContentSize: CGSize {
        if let labelSize = label?.intrinsicContentSize {
            var dimension = round(max(labelSize.height, labelSize.width))

            dimension += 8.0

            return CGSize(width: dimension, height: dimension)
        }

        return super.intrinsicContentSize
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let backgroundLayer = backgroundLayer,
           let label = label {
            updatePath(for: backgroundLayer, label: label)
        }
    }

    func updatePath(for backgroundLayer: CAShapeLayer, label: UILabel) {
        var insetBounds = label.frame.integral
        let dimension = max(insetBounds.height, insetBounds.width)

        insetBounds.size = CGSize(width: dimension, height: dimension)

        if backgroundLayer.frame != insetBounds
            || backgroundLayer.path == nil {
            backgroundLayer.frame = insetBounds
            var pathRect = insetBounds
            pathRect.origin = CGPoint.zero
            backgroundLayer.path = UIBezierPath(ovalIn: pathRect).cgPath
            backgroundLayer.position = insetBounds.center
        }
    }

    public func apply(styles: AppStyles) {
        label?.font = styles.fonts.sansSerif.caption1
        invalidateIntrinsicContentSize()
    }
}

@IBDesignable public class WarningBubbleLabel: BubbleLabel {
    public static var warningColor = UIColor.systemOrange
    public static var errorColor = UIColor(hex: "#E01622")

    @IBInspectable public var fillColor: UIColor = WarningBubbleLabel.errorColor {
        didSet {
            setupBackgroundView()
        }
    }

    override func setupBackgroundView() {
        super.setupBackgroundView()

        if let backgroundLayer = backgroundLayer {
            backgroundLayer.fillColor = fillColor.cgColor
            backgroundLayer.strokeColor = UIColor.white.cgColor
            backgroundLayer.lineWidth = 1.0
        }
    }

    override func updatePath(for backgroundLayer: CAShapeLayer, label _: UILabel) {
        backgroundLayer.bounds = bounds.integral
        let size = backgroundLayer.bounds.size

        let path = CGMutablePath()

        let radius: CGFloat = 4.0
        path.addPath(equilateralTriangle(width: size.width, height: size.height, radius: radius), transform: CGAffineTransform(translationX: 0.0, y: -radius))

        backgroundLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundLayer.path = path
        backgroundLayer.position = bounds.center
    }

    func equilateralTriangle(width: CGFloat, height: CGFloat, radius: CGFloat) -> CGPath {
        let point1 = CGPoint(x: -width / 2, y: height / 2)
        let point2 = CGPoint(x: 0, y: -height / 2)
        let point3 = CGPoint(x: width / 2, y: height / 2)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: radius)
        path.closeSubpath()

        return path
    }

    override public func apply(styles: AppStyles) {
        label?.font = styles.fonts.sansSerif.body.fontWith(weight: .black)
        invalidateIntrinsicContentSize()
    }
}
