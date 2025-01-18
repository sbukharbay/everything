//
//  DepositAccountCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 20/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class DepositAccountCell: UITableViewCell, TableViewElement, Stylable {
    @IBOutlet var accountDetails: UILabel?
    @IBOutlet var balance: UILabel?
    @IBOutlet var accessoryImage: UIImageView?

    static var reuseIdentifier: String = "DepositAccountCell"
    var viewModel: DepositAccountViewModel?

    func bind(account: DepositAccount, styles: AppStyles) {
        viewModel = DepositAccountViewModel(view: self, depositAccount: account, styles: styles)
        apply(styles: styles)
    }

    func apply(styles: AppStyles) {
        viewModel?.updateDescription(styles: styles)
        contentView.style(styles: styles)
    }
}

extension DepositAccountCell: DepositAccountView {
    func set(accountDescription: NSAttributedString?) {
        accountDetails?.attributedText = accountDescription
    }

    func set(accountBalance: String?) {
        balance?.text = accountBalance
    }

    func set(isSelected: Bool) {
        accessoryImage?.alpha = isSelected ? 1.0 : 0.0
    }
}
