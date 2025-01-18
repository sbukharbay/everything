//
//  SetSalaryCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

class SetSalaryCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var incomeData: IncomeStatusDataModel?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool

    init(presenter: UINavigationController, incomeData: IncomeStatusDataModel? = nil, getStartedType: GetStartedViewType? = nil, isSettings: Bool = false) {
        self.presenter = presenter
        self.incomeData = incomeData
        self.getStartedType = getStartedType
        self.isSettings = isSettings
    }
}

extension SetSalaryCoordinator: Coordinator {
    func start() {
        if let presenter = presenter {
            let viewController = SetSalaryViewController()
            viewController.bind(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
