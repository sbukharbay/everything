//
//  ConfirmationAlertView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 09.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public final class ConfirmationAlertView: UIView {
    private let titleLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
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

    public init(style: AppStyles, title: String, buttonTitle: String, buttonAction: (() -> Void)?) {
        super.init(frame: .zero)

        button.setTitle(buttonTitle, for: .normal)
        titleLabel.text = title
        self.buttonAction = buttonAction

        setupViews()
        self.style(styles: style)
    }

    private func setupViews() {
        backgroundColor = UIColor(hex: "0F0728")

        [titleLabel, button].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.widthAnchor.constraint(equalToConstant: 144)
        ])
    }

    @objc private func handleButton() {
        buttonAction?()
    }
}
