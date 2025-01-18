//
//  ChooseProviderCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit

class ChooseProviderCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var addedSavings: Bool?
    var isSettings: Bool = false
    var getStartedType: GetStartedViewType?
    
    init(presenter: UINavigationController, addedSavings: Bool? = nil, isSettings: Bool = false, getStartedType: GetStartedViewType? = nil) {
        self.presenter = presenter
        self.addedSavings = addedSavings
        self.isSettings = isSettings
        self.getStartedType = getStartedType
    }
}

extension ChooseProviderCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = ChooseProviderViewController()
            viewController.bind(addedSavings: addedSavings, isSettings: isSettings, getStartedType: getStartedType)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
