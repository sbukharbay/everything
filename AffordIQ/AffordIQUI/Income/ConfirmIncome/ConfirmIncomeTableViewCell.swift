//
//  ConfirmIncomeTableViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 16/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class ConfirmIncomeTableViewCell: UITableViewCell, Stylable {
    private let rightIconChevron: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor(hex: "#72F0F0")
        return imageView
    }()

    let subTitle: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    let userValueLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [subTitle, userValueLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 4
        
        return stackView
    }()

    static var reuseIdentifier = "ConfirmIncomeTableViewCell"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }

    private func setupLayout() {
        [horizontalStackView, rightIconChevron].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            rightIconChevron.leadingAnchor.constraint(equalTo: horizontalStackView.trailingAnchor, constant: 8),
            rightIconChevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            rightIconChevron.widthAnchor.constraint(equalToConstant: 20),
            rightIconChevron.heightAnchor.constraint(equalToConstant: 20),
            rightIconChevron.centerYAnchor.constraint(equalTo: userValueLabel.centerYAnchor),
            
            userValueLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }

    func groupCell(row: Int) {
        if row == 1 {
            horizontalStackView.alignment = .bottom
        } else if row == 2 {
            horizontalStackView.alignment = .top
        }
    }
}
