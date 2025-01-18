//
//  AccountDetailsCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class AccountDetailsCoordinator: NSObject {
    weak var presenter: UINavigationController?
    let account: InstitutionAccount
    let isLast: Bool
    weak var delegate: AccountDeletionDelegate?
    var institutionAccounts: [InstitutionAccount]
    
    init(presenter: UINavigationController,
         account: InstitutionAccount,
         delegate: AccountDeletionDelegate,
         institutionAccounts: [InstitutionAccount],
         isLast: Bool) {
        self.presenter = presenter
        self.account = account
        self.institutionAccounts = institutionAccounts
        self.delegate = delegate
        self.isLast = isLast
    }
}

extension AccountDetailsCoordinator: Coordinator {
    func start() {
        if let presenter = presenter {
            let viewController = AccountDetailsViewController()
            viewController.bind(account: account, delegate: delegate, institutionAccounts: institutionAccounts, isLast: isLast)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
