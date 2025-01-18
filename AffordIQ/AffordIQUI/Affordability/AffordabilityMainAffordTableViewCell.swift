//
//  AffordabilityMainAffordTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 17.02.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class AffordabilityMainAffordTableViewCell: UITableViewCell, Stylable {
    var titleLabel = BodyLabelDark()
    var amountLabel = BodyLabelDark()
    var percentageLabel = BodyLabelDark()
    let chevronImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "chevron.down")
        icon.tintColor = UIColor(hex: "#72F0F0")
        icon.isHidden = true
        return icon
    }()

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
        backgroundColor = .clear
        selectionStyle = .none
    }

    static var reuseIdentifier = "AffordabilityMainAfford"

    func setupView() {
        [titleLabel, percentageLabel, chevronImageView, amountLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            percentageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            percentageLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),

            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.leadingAnchor.constraint(equalTo: percentageLabel.trailingAnchor, constant: 8),

            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
