//
//  LinkAccountsInformationViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 25/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

class LinkAccountsInformationViewModel {
    let pages: [Page]
    
    init() {
        pages = [
            Page(
                imageName: "linked_accounts",
                headerText: "Link Bank Accounts",
                bodyText: "To buy your first home you must understand what you can afford to buy. Your income, spending and savings together determine your affordability."
                    + "\n\nIf you use online or mobile banking, all of your financial transactions are accessible via Open Banking."
                    + "\n\nBy linking all of your bank accounts, held at all institutions you will be able to see your complete financial landscape in one place and together we can understand what you can afford to buy."
            ),
            Page(
                imageName: "linked_accounts",
                headerText: "Link Bank Accounts",
                bodyText: "affordIQ uses the secure Open Banking provider TrueLayer to give you access to all of your transactional data from all bank accounts."
                    + "\n\nYou will not be giving permission for payments and money transfers to be made via the affordIQ App."
                    + "\n\nPlease link all bank accounts held at all of your banking institutions, including everyday accounts and savings accounts (if your bank allows)."
            )
        ]
    }
}
