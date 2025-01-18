//
//  SelfEmployedTypeCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 12.12.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

class SelfEmployedTypeCoordinator: NSObject {
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

extension SelfEmployedTypeCoordinator: Coordinator {
    func start() {
        if let presenter = presenter {
            let viewController = SelfEmployedTypeViewController()
            viewController.bind(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
