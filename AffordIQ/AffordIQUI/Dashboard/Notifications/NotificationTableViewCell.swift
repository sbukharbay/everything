//
//  NotificationTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 04.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class NotificationTableViewCell: UITableViewCell {
    private lazy var titleLabel = HeadlineLabelLight()
    private lazy var dayLabel = InfoLabelLight()

    private lazy var descriptionLabel: FieldLabelSubheadlineLight = {
        let label = FieldLabelSubheadlineLight()
        label.numberOfLines = 0
        
        return label
    }()

    static var reuseIdentifier = "NotificationTableViewCell"

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

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"

        titleLabel.textAlignment = .left

        dayLabel.textAlignment = .right

        [titleLabel, dayLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            dayLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func setupNotification(_ notification: NotificationDTO) {
        titleLabel.text = notification.title
        descriptionLabel.text = notification.description
        dayLabel.text = notification.date.descriptiveString()
    }
}
