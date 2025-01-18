//
//  OnboardingCompleteCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 16/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class OnboardingCompleteCoordinator: NSObject {
    weak var presenter: UINavigationController?

    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension OnboardingCompleteCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = OnboardingCompleteViewController()
            viewController.bind()

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
