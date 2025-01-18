//
//  SavingBudgetCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 28/06/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class SavingBudgetCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var isDashboard: Bool

    init(presenter: UINavigationController, isDashboard: Bool) {
        self.presenter = presenter
        self.isDashboard = isDashboard
    }
}

extension SavingBudgetCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = SavingBudgetViewController()
            viewController.bind(isDashboard: isDashboard)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
