//
//  AccountConsentCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit
import AffordIQControls

class AccountConsentCell: UITableViewCell, TableViewElement, Stylable {
    @IBOutlet var consentDescription: UILabel?
    static var reuseIdentifier = "AccountConsentCell"

    func bind(consent: OpenBankingConsent.ConsentScope) {
        switch consent {
        case .none:
            set(text: NSLocalizedString("• Nothing shared", bundle: uiBundle, comment: "Open Banking No Scope"))
        case .accounts:
            set(text: NSLocalizedString("• Your account details", bundle: uiBundle, comment: "Open Banking Accounts Scope"))
        case .balances:
            set(text: NSLocalizedString("• Your account balance", bundle: uiBundle, comment: "Open Banking Balances Scope"))
        case .info:
            set(text: NSLocalizedString("• Your identity information", bundle: uiBundle, comment: "Open Banking Info Scope"))
        case .offlineAccess:
            set(text: NSLocalizedString("• Offline access to your accounts", bundle: uiBundle, comment: "Open Banking Offline Scope"))
        case .transactions:
            set(text: NSLocalizedString("• Your account transactions", bundle: uiBundle, comment: "Open Banking Transactions Scope"))
        case .cards:
            set(text: NSLocalizedString("• Your card details", bundle: uiBundle, comment: "Open Banking Card Details Scope"))
        case .directDebits:
            set(text: NSLocalizedString("• Your direct debit details", bundle: uiBundle, comment: "Open Banking Direct Debit Details Scope"))
        case .standingOrders:
            set(text: NSLocalizedString("• Your standing order details", bundle: uiBundle, comment: "Open Banking Standing Order Details Scope"))
        }

        apply(styles: AppStyles.shared)
    }

    func set(text: String?) {
        consentDescription?.text = text
    }
}
