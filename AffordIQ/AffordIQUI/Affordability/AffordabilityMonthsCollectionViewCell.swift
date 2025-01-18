//
//  AffordabilityMonthsCollectionViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 15.02.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class AffordabilityMonthsCollectionViewCell: UICollectionViewCell, ReusableElement, Stylable {
    lazy var rectangleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.layer.cornerRadius = 6
        view.layer.borderColor = UIColor(hex: "72F0F0").cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        return view
    }()

    lazy var label: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .center
        return label
    }()

    static var reuseIdentifier: String = "AffordabilityMonths"

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        [rectangleView, label].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            rectangleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            rectangleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            rectangleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rectangleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1)
        ])
    }
}
