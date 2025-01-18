//
//  AffordabilityMainOverlayFooterView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 21.02.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class AffordabilityMainOverlayFooterView: UITableViewHeaderFooterView, Stylable {
    private let headerLabel: FieldLabelSubheadlineLight = .init()

    static var reuseIdentifier = "AffordabilityMainOverlayFooter"

    func setup(title: String) {
        headerLabel.text = title
        headerLabel.numberOfLines = 0

        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        backgroundView = bgView
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
