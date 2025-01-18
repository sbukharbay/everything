//
//  SetSavingsGoalCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 24/02/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class SetSavingsGoalCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var isDashboard: Bool

    init(presenter: UINavigationController, isDashboard: Bool = false) {
        self.presenter = presenter
        self.isDashboard = isDashboard
    }
}

extension SetSavingsGoalCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = SetSavingsGoalViewController()
            viewController.bind(isDashboard: isDashboard)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
