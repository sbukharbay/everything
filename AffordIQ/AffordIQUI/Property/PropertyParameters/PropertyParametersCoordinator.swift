//
//  PropertyParametersCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

class PropertyParametersCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var chosenParameters: ChosenPropertyParameters?
    var homeValue: Decimal
    var isDashboard: Bool
    var months: Int

    init(
        presenter: UINavigationController,
        homeValue: Decimal,
        parameters: ChosenPropertyParameters? = nil,
        months: Int,
        isDashboard: Bool = false) {
            self.presenter = presenter
            self.chosenParameters = parameters
            self.homeValue = homeValue
            self.isDashboard = isDashboard
            self.months = months
    }
}

extension PropertyParametersCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = PropertyParametersViewController()
            viewController.bind(
                homeValue: homeValue,
                parameters: chosenParameters,
                months: months,
                isDashboard: isDashboard
            )

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
