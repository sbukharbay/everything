//
//  FullScreenAlertView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 03.02.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public final class FullScreenAlertView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "72F0F0")
        return imageView
    }()

    private lazy var titleLabel = HeadingTitleLabel()

    private lazy var topStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 16
        return view
    }()

    private let messageLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var button: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        return button
    }()

    private var buttonAction: (() -> Void)?

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(title: String, icon: UIImage? = nil, message: String, buttonTitle: String, buttonAction: (() -> Void)?) {
        messageLabel.text = message
        self.buttonAction = buttonAction
        iconImageView.image = icon

        super.init(frame: .zero)

        titleLabel.text = title
        button.setTitle(buttonTitle, for: .normal)

        setupViews()
    }

    private func setupViews() {
        backgroundColor = UIColor(hex: "0F0728")

        [topStackView, messageLabel, button].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            topStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),

            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            messageLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 32),

            button.widthAnchor.constraint(equalToConstant: 160),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            button.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 24),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func handleButton() {
        buttonAction?()
    }
}
