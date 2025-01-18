//
//  PropertyLoadingCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 30/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class PropertyLoadingCell: UITableViewCell, Stylable, TableViewElement {
    @IBOutlet var blur: UIView?

    static var reuseIdentifier = "PropertyLoadingCell"

    func bind(styles: AppStyles) {
        blur?.layer.cornerRadius = 8.0
        blur?.layer.masksToBounds = true
        apply(styles: styles)
    }

    func apply(styles: AppStyles) {
        contentView.style(styles: styles)
    }
}
