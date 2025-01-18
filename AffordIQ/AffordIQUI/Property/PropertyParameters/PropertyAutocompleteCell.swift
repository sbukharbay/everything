//
//  PropertyAutocompleteCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 13.10.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class PropertyAutocompleteCell: UITableViewCell, Stylable {
    var titleLabel = BodyLabelDark()

    static var reuseIdentifier = "PropertyAutocompleteCell"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
        backgroundColor = UIColor(hex: "#0F0728")
        selectionStyle = .none
    }

    func setupLayout() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
