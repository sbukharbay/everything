//
//  SelfEmployedInformationCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 06.02.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

class SelfEmployedInformationCoordinator: NSObject {
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

extension SelfEmployedInformationCoordinator: Coordinator {
    func start() {
        if let presenter = presenter {
            let viewController = SelfEmployedInformationViewController()
            viewController.bind(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
