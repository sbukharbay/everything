//
//  SpendingSummaryCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 10/02/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class SpendingSummaryCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool
    var isRecategorisationFlow: Bool

    init(presenter: UINavigationController, getStartedType: GetStartedViewType?, isSettings: Bool = false, isRecategorisationFlow: Bool = false) {
        self.presenter = presenter
        self.getStartedType = getStartedType
        self.isSettings = isSettings
        self.isRecategorisationFlow = isRecategorisationFlow
    }
}

extension SpendingSummaryCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = SpendingSummaryViewController()
            viewController.bind(
                getStartedType: getStartedType,
                isSettings: isSettings,
                isRecategorisationFlow: isRecategorisationFlow
            )

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
