//
//  BudgetOverlayHeaderView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 31.08.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class BudgetOverlayHeaderView: UITableViewHeaderFooterView, Stylable {
    private let headerLabel: InfoLabel = .init()
    static var reuseIdentifier = "BudgetOverlayHeaderView"

    func setup(title: String) {
        headerLabel.text = title
        headerLabel.numberOfLines = 0

        let bgView = UIView()
        bgView.backgroundColor = UIColor.white
        backgroundView = bgView
        contentView.backgroundColor = .white
        backgroundColor = .white

        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
