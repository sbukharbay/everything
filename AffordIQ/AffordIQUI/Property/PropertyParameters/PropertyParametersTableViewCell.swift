//
//  PropertyParametersTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 16.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class PropertyParametersTableViewCell: UITableViewCell, Stylable {
    var titleLabel = BodyLabelDark()
    var valueLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.textAlignment = .center
        return label
    }()

    let chevronIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(systemName: "chevron.down"))
        icon.tintColor = .white
        return icon
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel, chevronIcon])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.setCustomSpacing(8, after: valueLabel)
        return stackView
    }()

    static var reuseIdentifier = "PropertyParametersTableViewCell"

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
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            chevronIcon.widthAnchor.constraint(equalToConstant: 14),
            chevronIcon.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
}
