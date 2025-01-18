//
//  CustomNavigationBar.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 13.10.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public final class CustomNavigationBar: UIView {
    private var leftButton: StandardButton = .init()
    private var rightButton: StandardButton = .init()

    private let titleLabel: HeadingLabelInfo = {
        let label = HeadingLabelInfo()
        label.textAlignment = .center
        label.text = "Get Started"
        return label
    }()

    private let backgroundBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    private lazy var filterButton: InlineButtonDark = {
        let button = InlineButtonDark()
        button.setTitle("  Filters", for: .normal)
        let buttonImage = UIImage(systemName: "slider.horizontal.3")
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(handleFilter), for: .touchUpInside)
        button.contentVerticalAlignment = .center
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -2, right: 0)
        return button
    }()

    private lazy var whenButton: InlineButtonDark = {
        let button = InlineButtonDark()
        button.setTitle("  When", for: .normal)
        let buttonImage = UIImage(systemName: "clock")
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(handleWhen), for: .touchUpInside)
        button.contentVerticalAlignment = .center
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -2, right: 0)
        return button
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [filterButton, whenButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private var leftButtonAction: (() -> Void)?
    private var rightButtonAction: (() -> Void)?
    private var filterButtonAction: (() -> Void)?
    private var whenButtonAction: (() -> Void)?
    private var bottomConstraint: NSLayoutConstraint?

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(title: String, rightButtonTitle: String? = nil,
                leftButtonAction: (() -> Void)?,
                rightButtonAction: (() -> Void)? = nil) {
        if title.isEmpty {
            titleLabel.isHidden = true
        } else {
            titleLabel.text = title
        }

        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction

        super.init(frame: .zero)

        leftButton = {
            let button = InlineButtonDark()
            button.setImage(.init(systemName: "chevron.left"), for: .normal)
            button.contentHorizontalAlignment = .leading
            button.contentVerticalAlignment = .center
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: -2, right: 0)
            button.addTarget(self, action: #selector(handleLeftButton), for: .touchUpInside)
            return button
        }()

        rightButton = {
            let button = InlineButtonDark()
            if #available(iOS 14.0, *) {
                button.setImage(.init(systemName: "chevron.backward"), for: .normal)
            } else {
                button.setImage(.init(systemName: "chevron.left"), for: .normal)
            }
            button.contentHorizontalAlignment = .leading
            button.contentVerticalAlignment = .center
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -2, right: 8)
            button.semanticContentAttribute = .forceRightToLeft
            button.addTarget(self, action: #selector(handleRightButton), for: .touchUpInside)
            return button
        }()

        leftButton.setTitle("Back", for: .normal)

        if let title = rightButtonTitle {
            rightButton.setTitle(title, for: .normal)
        } else {
            rightButton.isHidden = true
        }

        addSubview(backgroundBlur)
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false

        setupViews()

        NSLayoutConstraint.activate([
            backgroundBlur.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundBlur.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundBlur.topAnchor.constraint(equalTo: topAnchor),
            backgroundBlur.bottomAnchor.constraint(equalTo: bottomAnchor),

            leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }

    public init(leftButtonAction: (() -> Void)?, rightButtonAction: (() -> Void)? = nil) {
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction

        super.init(frame: .zero)

        leftButton = {
            let button = InlineButtonWhite()
            button.contentHorizontalAlignment = .leading
            button.contentVerticalAlignment = .center
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            button.addTarget(self, action: #selector(handleLeftButton), for: .touchUpInside)
            return button
        }()

        rightButton = {
            let button = InlineButtonWhite()
            button.contentHorizontalAlignment = .leading
            button.contentVerticalAlignment = .center
            button.semanticContentAttribute = .forceRightToLeft
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            button.addTarget(self, action: #selector(handleRightButton), for: .touchUpInside)
            return button
        }()

        leftButton.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        rightButton.setImage(UIImage(systemName: "bell"), for: .normal)
        titleLabel.isHidden = true

        setupViews()

        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            leftButton.widthAnchor.constraint(equalToConstant: 24),
            leftButton.heightAnchor.constraint(equalToConstant: 24),
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            rightButton.widthAnchor.constraint(equalToConstant: 24),
            rightButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func setupViews() {
        backgroundColor = .clear

        [leftButton, titleLabel, rightButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        bottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        NSLayoutConstraint.activate([
            leftButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor),
            bottomConstraint!,

            rightButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }

    public func addFiltersSection(filterAction: (() -> Void)?, whenAction: (() -> Void)?) {
        filterButtonAction = filterAction
        whenButtonAction = whenAction

        backgroundBlur.layer.cornerRadius = 30
        backgroundBlur.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundBlur.clipsToBounds = true

        [bottomStackView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        bottomConstraint?.constant = -72

        NSLayoutConstraint.activate([
            bottomStackView.heightAnchor.constraint(equalToConstant: 60),
            bottomStackView.leadingAnchor.constraint(equalTo: backgroundBlur.leadingAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: backgroundBlur.trailingAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: backgroundBlur.bottomAnchor)
        ])
    }

    public func addRightButton(title: String, action: (() -> Void)?) {
        rightButtonAction = action
        rightButton.setTitle(title, for: .normal)
        rightButton.isHidden = false
    }

    public func addRightButton(image: UIImage, color: UIColor, action: (() -> Void)?) {
        rightButtonAction = action
        rightButton.setImage(image, for: .normal)
        rightButton.tintColor = color
        rightButton.isHidden = false
    }

    public func hideRightButton(hide: Bool) {
        rightButton.isHidden = hide
    }

    public func setTitle(text: String) {
        titleLabel.isHidden = false
        titleLabel.text = text
    }

    public func renameRightButtonTitle(text: String) {
        rightButton.setTitle(text, for: .normal)
    }

    public func hideLeftButton(hide: Bool) {
        leftButton.isHidden = hide
    }

    public func renameLeftButton(setTitle: String) {
        leftButton.setTitle(setTitle, for: .normal)
    }

    public func removeBlurView() {
        backgroundBlur.removeFromSuperview()
    }

    public func rightButton(isEnabled: Bool) {
        rightButton.isEnabled = isEnabled
    }

    public func removeRightButtonChevron() {
        rightButton.setImage(nil, for: .normal)
    }
    
    @objc private func handleRightButton() {
        rightButtonAction?()
    }

    @objc private func handleLeftButton() {
        leftButtonAction?()
    }

    @objc private func handleFilter() {
        filterButtonAction?()
    }

    @objc private func handleWhen() {
        whenButtonAction?()
    }
}
