//
//  AnimatedBlurView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 29/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class AnimatedBlurView: UIVisualEffectView {
    private var animator: UIViewPropertyAnimator!
    private var delta: CGFloat = 0
    private var target: CGFloat = 0
    private var isBlurred = false
    private weak var displayLink: CADisplayLink?

    private let disableAnimations: Bool = {
        ProcessInfo.processInfo.environment["DISABLEBLURANIMATIONS"] == "true"
    }()

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    deinit {
        displayLink?.invalidate()
    }

    private func setup() {
        effect = nil
        isHidden = true

        if !disableAnimations {
            animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
                self.effect = UIBlurEffect(style: .systemMaterialDark)
            }

            animator.pausesOnCompletion = true

            let newDisplayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
            newDisplayLink.isPaused = true
            newDisplayLink.add(to: .main, forMode: RunLoop.Mode.common)
            displayLink = newDisplayLink
        }
    }

    public func blurIn(amount: CGFloat = 1.0, duration: TimeInterval = 0.3) {
        guard !isBlurred else {
            return
        }

        isHidden = false

        if !disableAnimations {
            target = amount
            delta = amount / (60 * CGFloat(duration))
            displayLink?.isPaused = false
        } else {
            effect = UIBlurEffect(style: .systemMaterialDark)
        }
    }

    public func blurOut(duration: TimeInterval = 0.3) {
        guard isBlurred else {
            return
        }

        if disableAnimations {
            isHidden = true
            effect = nil
        } else {
            target = 0
            delta = -1 * animator.fractionComplete / (60 * CGFloat(duration))
            displayLink?.isPaused = false
        }
    }

    @objc private func tick(_: Any?) {
        animator.fractionComplete += delta

        if isBlurred && animator.fractionComplete <= 0 {
            isBlurred = false
            isHidden = true
            displayLink?.isPaused = true
            animator.fractionComplete = 0.0
        } else if !isBlurred && animator.fractionComplete >= target {
            isBlurred = true
            displayLink?.isPaused = true
            animator.fractionComplete = target
        }
    }
}
