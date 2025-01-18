//
//  ThreeStageMeter.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 31/03/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

@IBDesignable public class ThreeStageMeter: UIView {
    class GradientView: UIView {
        override class var layerClass: AnyClass { CAGradientLayer.classForCoder() }

        func setColors(color1: UIColor, color2: UIColor) {
            if let layer = layer as? CAGradientLayer {
                layer.colors = [color1, color2].map { $0.cgColor }
                layer.startPoint = CGPoint(x: 0.0, y: 0.5)
                layer.endPoint = CGPoint(x: 1.0, y: 0.5)
                setNeedsDisplay()
            }
        }
    }

    weak var stage1: GradientView?
    weak var stage2: GradientView?
    weak var stage3: GradientView?
    weak var background: GradientView?

    weak var stage1Width: NSLayoutConstraint?
    weak var stage2Width: NSLayoutConstraint?

    @IBInspectable public var stage1Color1: UIColor = .systemRed {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var stage1Color2: UIColor = .systemOrange {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var stage2Color1: UIColor = .systemBlue {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var stage2Color2: UIColor = .systemTeal {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var stage3Color1: UIColor = .clear {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var stage3Color2: UIColor = .clear {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var backgroundColor1: UIColor = UIColor.white.withAlphaComponent(0.0) {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var backgroundColor2: UIColor = UIColor.white.withAlphaComponent(1.0) {
        didSet {
            colorsUpdated()
        }
    }

    @IBInspectable public var stage1Proportion: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable public var stage2Proportion: CGFloat = 0.25 {
        didSet {
            setNeedsLayout()
        }
    }

    public var stage3Proportion: CGFloat {
        min(1.0, max(0.0, 1.0 - stage1Proportion - stage2Proportion))
    }

    private func colorsUpdated() {
        stage1?.setColors(color1: stage1Color1, color2: stage1Color2)
        stage2?.setColors(color1: stage2Color1, color2: stage2Color2)
        stage3?.setColors(color1: stage3Color1, color2: stage3Color2)
        background?.setColors(color1: backgroundColor1, color2: backgroundColor2)
    }

    private func proportionsUpdated() {
        stage1Width?.constant = bounds.size.width * stage1Proportion
        stage2Width?.constant = bounds.size.width * stage2Proportion
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func addStage(stackView: UIStackView) -> GradientView {
        var stageFrame = stackView.bounds
        stageFrame.size.width /= 3.0

        let newStage = GradientView(frame: stageFrame)
        stackView.addArrangedSubview(newStage)

        return newStage
    }

    private func addConstraints() {
        guard let stage1 = stage1,
              let stage2 = stage2
        else {
            return
        }

        let width = bounds.size.width
        let stage1WidthConstraint = NSLayoutConstraint(item: stage1, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width * stage1Proportion)
        stage1WidthConstraint.priority = .defaultHigh
        let stage2WidthConstraint = NSLayoutConstraint(item: stage2, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width * stage2Proportion)
        stage2WidthConstraint.priority = .defaultHigh

        stage1.addConstraint(stage1WidthConstraint)
        stage2.addConstraint(stage2WidthConstraint)

        stage1Width = stage1WidthConstraint
        stage2Width = stage2WidthConstraint
    }

    private func addBackground() -> GradientView {
        let newBackground = GradientView(frame: bounds)
        insertSubview(newBackground, at: 0)
        newBackground.pinToSuperview()

        return newBackground
    }

    private func setup() {
        backgroundColor = UIColor.clear

        let stackView = UIStackView(frame: bounds)
        stackView.backgroundColor = UIColor.clear
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.pinToSuperview()

        stage1 = addStage(stackView: stackView)
        stage2 = addStage(stackView: stackView)
        stage3 = addStage(stackView: stackView)

        background = addBackground()

        addConstraints()
        colorsUpdated()
    }

    override public func layoutSubviews() {
        proportionsUpdated()
        super.layoutSubviews()
    }
}
