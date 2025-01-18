//
//  DashboardSettingsCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 04/08/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

class DashboardSettingsCoordinator: NSObject {
    weak var presenter: UINavigationController?

    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension DashboardSettingsCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = DashboardSettingsViewController()
            viewController.bind()
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
