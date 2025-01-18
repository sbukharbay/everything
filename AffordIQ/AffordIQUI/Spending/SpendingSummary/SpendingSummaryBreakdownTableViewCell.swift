//
//  SpendingSummaryBreakdownTableViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 15/02/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class SpendingSummaryBreakdownTableViewCell: UITableViewCell, Stylable {
    let categoryLabel: FieldLabelSubheadlineLightBold = {
        let label = FieldLabelSubheadlineLightBold()
        label.textAlignment = .left
        return label
    }()

    let averageSpend: FieldLabelSubheadlineLight = {
        let label = FieldLabelSubheadlineLight()
        label.textAlignment = .right
        return label
    }()

    static var reuseIdentifier = "CategoryBreakdown"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder: has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }

    func setupLayout() {
        [categoryLabel, averageSpend].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            averageSpend.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            averageSpend.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
