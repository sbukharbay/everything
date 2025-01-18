//
//  SpendingCategoryHeaderViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 31/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class SpendingCategoryHeaderViewCell: UITableViewCell, Stylable {
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = UIColor(hex: "#72F0F0")
        return button
    }()

    let iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        icon.tintColor = UIColor(hex: "#72F0F0")
        return icon
    }()

    private let parentCategoryLabel = HeadlineLabelDark()

    private lazy var categoryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, iconImageView, parentCategoryLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.setCustomSpacing(12, after: backButton)
        stackView.setCustomSpacing(12, after: iconImageView)
        return stackView
    }()

    static var reuseIdentifier = "ParentCategory"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
    }

    func setup(with data: SpendingCategoriesModel) {
        if data.icon.lowercased() == data.categoryName.lowercased() {
            iconImageView.image = UIImage(named: data.icon, in: uiBundle, compatibleWith: nil)
        } else {
            iconImageView.image = UIImage(systemName: data.icon)
        }
        parentCategoryLabel.text = data.categoryName

        contentView.addSubview(categoryStackView)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            categoryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            iconImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
}
