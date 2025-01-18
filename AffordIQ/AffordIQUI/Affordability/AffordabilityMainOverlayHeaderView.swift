//
//  AffordabilityMainOverlayHeaderView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 21.02.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class AffordabilityMainOverlayHeaderView: UITableViewHeaderFooterView, Stylable {
    private let iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.tintColor = UIColor(hex: "#4FCED3")
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private let headerLabel: HeadingLabelLight = .init()
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, headerLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.setCustomSpacing(8, after: iconImageView)
        return stackView
    }()

    static var reuseIdentifier = "AffordabilityMainOverlayHeader"

    func setup(title: String, icon: UIImage) {
        headerLabel.text = title
        iconImageView.image = icon

        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        backgroundView = bgView
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(titleStackView)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            iconImageView.widthAnchor.constraint(equalToConstant: 32)
        ])
    }
}
