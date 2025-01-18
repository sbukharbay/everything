//
//  LinkAccountsCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 02/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit
import AffordIQFoundation

class LinkAccountsCoordinator: NSObject {
    weak var presenter: UINavigationController?
    let accounts: [InstitutionAccount]
    let institutionId: String
    var isDashboard = true
    var addedSavings: Bool?
    var isSettings: Bool = false
    var getStartedType: GetStartedViewType?
    
    init(presenter: UINavigationController, accounts: [InstitutionAccount], institutionId: String, isDashboard: Bool = true, addedSavings: Bool? = nil, isSettings: Bool = false, getStartedType: GetStartedViewType?) {
        self.presenter = presenter
        self.accounts = accounts
        self.institutionId = institutionId
        self.isDashboard = isDashboard
        self.addedSavings = addedSavings
        self.isSettings = isSettings
        self.getStartedType = getStartedType
    }
}

extension LinkAccountsCoordinator: Coordinator {
    func start() {
        if let presenter = presenter, let viewController = LinkAccountsViewController.instantiate() {
            viewController.bind(availableAccounts: accounts, institutionID: institutionId, isDashboard: isDashboard, addedSavings: addedSavings, isSettings: isSettings, getStartedType: getStartedType)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
