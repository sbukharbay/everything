//
//  RenewConsentCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 31.07.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

public class RenewConsentCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var accounts: [[InstitutionAccount]]
    var type: PreReconsentType
    
    public init(presenter: UINavigationController, accounts: [[InstitutionAccount]], preReconsentType: PreReconsentType? = nil) {
        self.presenter = presenter
        self.accounts = accounts
        self.type = preReconsentType ?? .reconsent
    }
}

extension RenewConsentCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = RenewConsentViewController()
            viewController.bind(accounts: accounts, preReconsentType: type)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
