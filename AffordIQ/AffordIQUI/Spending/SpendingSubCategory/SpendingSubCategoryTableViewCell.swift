//
//  SpendingSubCategoryTableViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 31/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class SpendingSubCategoryTableViewCell: UITableViewCell, Stylable {
    var subCategoryLabel = FieldLabelDark()

    let checkIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "checkmark.circle.fill")
        icon.tintColor = UIColor(hex: "#72F0F0")
        icon.isHidden = true
        return icon
    }()

    static var reuseIdentifier = "SpendingSubCategoryCell"

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
        [subCategoryLabel, checkIcon].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            subCategoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            subCategoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 58),

            checkIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            checkIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
