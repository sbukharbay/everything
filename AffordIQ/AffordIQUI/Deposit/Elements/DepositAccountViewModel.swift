//
//  DepositAccountViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 20/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

protocol DepositAccountView: AnyObject {
    func set(accountDescription: NSAttributedString?)
    func set(accountBalance: String?)
    func set(isSelected: Bool)
}

struct DepositAccountViewModel {
    let depositAccount: DepositAccount
    weak var view: DepositAccountView?

    init(view: DepositAccountView, depositAccount: DepositAccount, styles: AppStyles) {
        self.depositAccount = depositAccount
        self.view = view

        updateDescription(styles: styles)

        view.set(accountBalance: depositAccount.account.balance?.currentBalance.shortDescription ?? String.missingValuePlaceholder)
        view.set(isSelected: depositAccount.isSelected)
    }

    func updateDescription(styles: AppStyles) {
        let accountDescription = depositAccount.account.describe(showBalance: false, showProviderName: false, showAccountNumber: false, styles: styles)
        view?.set(accountDescription: accountDescription)
    }
}
