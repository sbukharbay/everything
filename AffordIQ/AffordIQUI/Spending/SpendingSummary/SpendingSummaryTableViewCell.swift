//
//  SpendingSummaryNonDiscretionaryTableCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 10/02/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class SpendingSummaryTableViewCell: UITableViewCell, Stylable {
    private let iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.tintColor = UIColor(hex: "#4FCED3")
        return icon
    }()

    private let categoryLabel: FieldLabelSubheadlineLightBold = {
        let label = FieldLabelSubheadlineLightBold()
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let averageSpend: FieldLabelSubheadlineLight = {
        let label = FieldLabelSubheadlineLight()
        label.textAlignment = .right
        return label
    }()

    private let chevronIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor(hex: "#4FCED3")
        return imageView
    }()

    static var reuseIdentifier = "AverageCategoryAmount"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
    }

    func setupLayout(with data: CategorisedTransactionsSummariesModel) {
        [iconImageView, categoryLabel, averageSpend, chevronIcon].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),

            categoryLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: averageSpend.leadingAnchor, constant: 8),

            averageSpend.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -8),
            averageSpend.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            chevronIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            chevronIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronIcon.heightAnchor.constraint(equalToConstant: 24),
            chevronIcon.widthAnchor.constraint(equalToConstant: 24)
        ])

        if data.icon.lowercased() == data.categoryName.lowercased() {
            iconImageView.image = UIImage(named: data.icon, in: uiBundle, compatibleWith: nil)
        } else {
            iconImageView.image = UIImage(systemName: data.icon)
        }
        categoryLabel.text = data.categoryName
        averageSpend.text = data.averageValue.longDescription
    }
}
