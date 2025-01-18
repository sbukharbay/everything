//
//  EmploymentStatusTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class EmploymentStatusTableViewCell: UITableViewCell, ReusableElement, Stylable {
    private let checkmarkIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = UIColor(hex: "#72F0F0")
        return imageView
    }()

    lazy var titleLabel = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        return label
    }()

    static var reuseIdentifier = "EmploymentStatusCell"

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

        [checkmarkIconImageView, titleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            checkmarkIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkIconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkmarkIconImageView.widthAnchor.constraint(equalToConstant: 32),
            checkmarkIconImageView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: checkmarkIconImageView.trailingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }

    func toggle(_ clicked: Bool) {
        checkmarkIconImageView.image = clicked ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
    }
    
    func disabled() {
        checkmarkIconImageView.image = UIImage(systemName: "circle")
        checkmarkIconImageView.tintColor = .lightGray
        titleLabel.textColor = .lightGray
    }
}
