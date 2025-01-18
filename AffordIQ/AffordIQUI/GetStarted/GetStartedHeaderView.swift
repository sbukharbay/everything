//
//  GetStartedHeaderView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 09.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class GetStartedHeaderView: UITableViewHeaderFooterView, Stylable {
    private let headerLabel: TitleLabelBlue = {
        let label = TitleLabelBlue()
        label.numberOfLines = 0
        return label
    }()

    static var reuseIdentifier = "GetStarted"

    func setup(title: String) {
        headerLabel.text = title

        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        backgroundView = bgView
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
