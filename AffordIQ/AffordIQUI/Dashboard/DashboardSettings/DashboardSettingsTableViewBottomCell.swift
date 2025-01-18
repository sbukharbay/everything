//
//  DashboardSettingsTableViewBottomCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 09/08/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class DashboardSettingsTableViewBottomCell: UITableViewCell, Stylable {
    private(set) lazy var titleLabel: HeadlineLabelLight = {
        let label = HeadlineLabelLight()
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var rightIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .black
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    static var reuseIdentifier = "DashboardSettingsTableViewBottomCell"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none

        [titleLabel, rightIconImageView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            rightIconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            rightIconImageView.widthAnchor.constraint(equalToConstant: 24),
            rightIconImageView.heightAnchor.constraint(equalToConstant: 24),
            rightIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
