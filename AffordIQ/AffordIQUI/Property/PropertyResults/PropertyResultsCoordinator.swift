//
//  PropertyResultsCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 21.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class PropertyResultsCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var mortgageLimits: MortgageLimits?
    var search: ChosenPropertyParameters
    var isDashboard: Bool
    var months: Int

    init(presenter: UINavigationController, search: ChosenPropertyParameters, mortgageLimits: MortgageLimits? = nil, months: Int, isDashboard: Bool) {
        self.presenter = presenter
        self.search = search
        self.mortgageLimits = mortgageLimits
        self.months = months
        self.isDashboard = isDashboard
    }
}

extension PropertyResultsCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = PropertyResultsViewController()
            viewController.bind(search: search, mortgageLimits: mortgageLimits, months: months, isDashboard: isDashboard)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
