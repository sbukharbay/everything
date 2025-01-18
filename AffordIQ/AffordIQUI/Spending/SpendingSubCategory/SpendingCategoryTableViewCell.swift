//
//  SpendingSubCategoryTableViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 27/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class SpendingCategoryTableViewCell: UITableViewCell, Stylable {
    let iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.tintColor = UIColor(hex: "#72F0F0")
        return icon
    }()

    let categoryLabel = BodyLabelDark()

    private lazy var categoryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, categoryLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.setCustomSpacing(12, after: iconImageView)
        return stackView
    }()

    static var reuseIdentifier = "SpendingCategoryCell"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
    }

    func setupLayout(with data: SpendingCategoriesModel) {
        [categoryStackView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            categoryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 20)
        ])

        if data.icon.lowercased() == data.categoryName.lowercased() {
            iconImageView.image = UIImage(named: data.icon, in: uiBundle, compatibleWith: nil)
        } else {
            iconImageView.image = UIImage(systemName: data.icon)
        }

        categoryLabel.text = data.categoryName
    }
}
