//
//  RenewConsentInformationCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 27.07.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

public class RenewConsentInformationCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var accounts: [[InstitutionAccount]]
    
    public init(presenter: UINavigationController, accounts: [[InstitutionAccount]]) {
        self.presenter = presenter
        self.accounts = accounts
    }
}

extension RenewConsentInformationCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = RenewConsentInformationViewController()
            viewController.bind(accounts: accounts)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
