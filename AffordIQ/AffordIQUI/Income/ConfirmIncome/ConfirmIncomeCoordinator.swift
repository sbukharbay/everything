//
//  ConfirmIncomeCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 15/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class ConfirmIncomeCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var incomeData: IncomeStatusDataModel?
    var getStartedType: GetStartedViewType?
    var isBack = false
    var isSettings = false

    init(presenter: UINavigationController, incomeData: IncomeStatusDataModel? = nil, getStartedType: GetStartedViewType? = nil, isBack: Bool = false, isSettings: Bool = false) {
        self.presenter = presenter
        self.incomeData = incomeData
        self.getStartedType = getStartedType
        self.isBack = isBack
        self.isSettings = isSettings
    }
}

extension ConfirmIncomeCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = ConfirmIncomeViewController()
            viewController.bind(incomeData: incomeData, getStartedType: getStartedType, isBack: isBack, isSettings: isSettings)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
