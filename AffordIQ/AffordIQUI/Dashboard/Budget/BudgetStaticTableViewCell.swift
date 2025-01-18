//
//  BudgetStaticTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 20.09.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class BudgetStaticTableViewCell: UITableViewCell, Stylable {
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#45AEBC")
        return imageView
    }()

    private var titleLabel = HeadlineLabelLight()

    private var valueLabel: SubTitleLabelLight = {
        let label = SubTitleLabelLight()
        label.textAlignment = .right
        return label
    }()

    private lazy var parentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [icon, titleLabel, valueLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(8, after: icon)
        stackView.alignment = .center
        return stackView
    }()

    static var reuseIdentifier = "BudgetStaticTableViewCell"

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

    private func setupLayout() {
        [parentStackView].forEach { view in
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            parentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            parentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            parentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            parentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            icon.widthAnchor.constraint(equalToConstant: 16)
        ])
    }

    func setData(data: BudgetDetailModel) {
        icon.image = UIImage(named: data.icon, in: uiBundle, with: nil)
        titleLabel.text = data.title
        valueLabel.text = data.value.amount ?? 0 <= 0 ? "£0" : data.value.longDescription
    }
}
