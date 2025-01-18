//
//  AlfiLoaderCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 27.01.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit
import AffordIQAuth0

public class AlfiLoaderCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var isSpending = false
    var getStartedType: GetStartedViewType
    
    public init(
        presenter: UINavigationController,
        isSpending: Bool = false,
        getStartedType: GetStartedViewType
    ) {
        self.presenter = presenter
        self.isSpending = isSpending
        self.getStartedType = getStartedType
    }
}

extension AlfiLoaderCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = AlfiLoaderViewController()
            viewController.bind(getStartedType: getStartedType, isSpending: isSpending)
            if !Auth0Session.shared.isOnboardingCompleted {
                presenter.setViewControllers([viewController], animated: true)
            } else {
                presenter.pushViewController(viewController, animated: true)
            }
        }
    }
}
