//
//  AccountsCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 28/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import Combine
import UIKit

class AccountsCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var isBack: Bool?
    var addedSavings: Bool?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool = false

    init(presenter: UINavigationController, isBack: Bool? = nil, addedSavings: Bool? = nil, getStartedType: GetStartedViewType? = nil, isSettings: Bool = false) {
        self.presenter = presenter
        self.isBack = isBack
        self.getStartedType = getStartedType
        self.addedSavings = addedSavings
        self.isSettings = isSettings
    }
}

extension AccountsCoordinator: Coordinator {
    func start() {
        if let presenter = presenter {
            let viewController = AccountsViewController()
            viewController.bind(isBack: isBack, getStartedType: getStartedType, addedSavings: addedSavings, isSettings: isSettings)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
