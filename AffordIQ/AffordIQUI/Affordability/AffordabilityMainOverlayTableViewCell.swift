//
//  AffordabilityMainOverlayTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 21.02.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class AffordabilityMainOverlayTableViewCell: UITableViewCell, Stylable {
    let icon: UIImageView = {
        let icon = UIImageView()
        icon.tintColor = UIColor(hex: "#4FCED3")
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    var titleLabel = FieldLabelSubheadlineLight()
    var valueLabel = FieldLabelSubheadlineLight()
    let chevronIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "chevron.right")
        icon.tintColor = UIColor(hex: "#4FCED3")
        icon.isHidden = true
        return icon
    }()

    static var reuseIdentifier = "AffordabilityMainOverlay"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
        backgroundColor = .clear
        selectionStyle = .none
    }

    func setupLayout() {
        [icon, titleLabel, chevronIcon, valueLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            icon.heightAnchor.constraint(equalToConstant: 24),
            icon.widthAnchor.constraint(equalToConstant: 24),

            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 16),

            chevronIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            chevronIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        if chevronIcon.isHidden {
            NSLayoutConstraint.activate([
                valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
                valueLabel.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -8)
            ])
        } else {
            NSLayoutConstraint.activate([
                valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
                valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])
        }
    }
}
