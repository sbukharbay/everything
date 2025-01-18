//
//  SelfEmployedProfitCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 08.12.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

class SelfEmployedProfitCoordinator: NSObject {
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

extension SelfEmployedProfitCoordinator: Coordinator {
    func start() {
        if let presenter = presenter {
            let viewController = SelfEmployedProfitViewController()
            viewController.bind(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
