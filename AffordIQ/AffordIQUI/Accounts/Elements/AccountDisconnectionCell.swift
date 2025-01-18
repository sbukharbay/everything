//
//  AccountDisconnectionCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 08/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

protocol AccountDisconnectionDelegate: AnyObject {
    func disconnect()
}

class AccountDisconnectionCell: UITableViewCell, Stylable, TableViewElement {
    static var reuseIdentifier = "AccountDisconnectionCell"
    weak var delegate: AccountDisconnectionDelegate?

    func bind(delegate: AccountDisconnectionDelegate?) {
        self.delegate = delegate
        apply(styles: AppStyles.shared)
    }

    @IBAction func disconnect(_: Any?) {
        delegate?.disconnect()
    }
}
