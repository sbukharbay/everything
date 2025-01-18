//
//  GetStartedTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 12.10.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class GetStartedTableViewCell: UITableViewCell, ReusableElement, Stylable {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let checkmarkIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = UIColor(hex: "#72F0F0")
        return imageView
    }()

    private let rightIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor(hex: "#72F0F0")
        return imageView
    }()

    private lazy var titleLabel: HeadlineLabelDark = {
        let view = HeadlineLabelDark()
        view.numberOfLines = 0
        view.textAlignment = .left
        
        return view
    }()

    private let descriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        return label
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        view.axis = .vertical
        view.distribution = .equalCentering
        return view
    }()

    static var reuseIdentifier = "GetStartedTableViewCell"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none

        [iconImageView, stackView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func setupImages() {
        [checkmarkIconImageView, rightIconImageView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            rightIconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            rightIconImageView.widthAnchor.constraint(equalToConstant: 24),
            rightIconImageView.heightAnchor.constraint(equalToConstant: 24),
            rightIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            checkmarkIconImageView.trailingAnchor.constraint(equalTo: rightIconImageView.leadingAnchor, constant: -8),
            checkmarkIconImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkIconImageView.heightAnchor.constraint(equalToConstant: 24),
            checkmarkIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func setupNoCheckMark() {
        [rightIconImageView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            rightIconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            rightIconImageView.widthAnchor.constraint(equalToConstant: 24),
            rightIconImageView.heightAnchor.constraint(equalToConstant: 24),
            rightIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func setupData(with data: Page, clickable: Bool) {
        iconImageView.image = UIImage(named: data.imageName, in: uiBundle, compatibleWith: nil)
        titleLabel.text = data.headerText

        if clickable {
            setupImages()
        } else {
            descriptionLabel.text = data.bodyText
        }
    }

    func dashboardSettingsData(with data: DashboardSettingsModel) {
        iconImageView.image = UIImage(named: data.icon, in: uiBundle, compatibleWith: nil)
        titleLabel.text = data.title

        setupNoCheckMark()
    }
}
