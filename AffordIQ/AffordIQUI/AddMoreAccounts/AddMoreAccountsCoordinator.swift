//
//  AddMoreAccountsCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 04/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class AddMoreAccountsCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool = false

    public init(presenter: UINavigationController, getStartedType: GetStartedViewType? = nil, isSettings: Bool = false) {
        self.presenter = presenter
        self.getStartedType = getStartedType
        self.isSettings = isSettings
    }
}

extension AddMoreAccountsCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = AddMoreAccountsViewController()
            viewController.bind(getStartedType: getStartedType, isSettings: isSettings)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
