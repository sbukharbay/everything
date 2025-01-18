//
//  BudgetDetailsCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 28.09.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class BudgetDetailsCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var spending: SpendingBreakdownCategory

    init(presenter: UINavigationController, spending: SpendingBreakdownCategory) {
        self.presenter = presenter
        self.spending = spending
    }
}

extension BudgetDetailsCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = BudgetDetailsViewController()
            viewController.bind(spending: spending)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
