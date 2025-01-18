//
//  CustomAlertView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 15.10.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public final class CustomAlertView: UIView {
    private let titleLabel: TitleLabelBlue = .init()

    private let messageLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        return label
    }()

    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [leftButton, rightButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 16
        return view
    }()

    private lazy var rightButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(handleRight), for: .touchUpInside)
        return button
    }()

    private lazy var leftButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor(hex: "72F0F0"), for: .normal)
        button.addTarget(self, action: #selector(handleLeft), for: .touchUpInside)
        return button
    }()

    private var leftButtonAction: (() -> Void)?
    private var rightButtonAction: (() -> Void)?

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(style: AppStyles, title: String, message: String, rightButtonTitle: String, leftButtonTitle: String? = nil, rightButtonAction: (() -> Void)?, leftButtonAction: (() -> Void)? = nil) {
        titleLabel.text = title
        messageLabel.text = message
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction

        super.init(frame: .zero)

        rightButton.setTitle(rightButtonTitle, for: .normal)

        if let title = leftButtonTitle {
            leftButton.setTitle(title, for: .normal)
        } else {
            leftButton.isHidden = true
        }

        setupViews()
        self.style(styles: style)
    }

    private func setupViews() {
        backgroundColor = UIColor(hex: "0F0728")
        layer.cornerRadius = 20
        layer.masksToBounds = true

        [titleLabel, messageLabel, buttonStackView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),

            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            buttonStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 32),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func handleRight() {
        rightButtonAction?()
    }

    @objc private func handleLeft() {
        leftButtonAction?()
    }
}
