//
//  PropertyNoResultsCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 02/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit
import AffordIQControls

protocol PropertyNoResultsDelegate: AnyObject {
    func goBack(_ sender: Any?)
    func changeFilter(_ sender: Any?)
}

class PropertyNoResultsCell: UITableViewCell, TableViewElement, Stylable {
    static var reuseIdentifier = "PropertyNoResultsCell"

    @IBOutlet var blur: UIView?

    weak var delegate: PropertyNoResultsDelegate?

    func bind(delegate: PropertyNoResultsDelegate?, styles: AppStyles) {
        self.delegate = delegate

        blur?.layer.cornerRadius = 8.0
        blur?.layer.masksToBounds = true
        apply(styles: styles)
    }

    func apply(styles: AppStyles) {
        contentView.style(styles: styles)
    }

    @IBAction func goBack(_ sender: Any?) {
        delegate?.goBack(sender)
    }

    @IBAction func changeFilter(_ sender: Any?) {
        delegate?.changeFilter(sender)
    }
}
