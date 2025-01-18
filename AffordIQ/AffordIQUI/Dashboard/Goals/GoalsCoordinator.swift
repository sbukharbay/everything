//
//  GoalsCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 07.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls

class GoalsCoordinator: NSObject {
    weak var presenter: UITabBarController?
    weak var navigationController: UINavigationController?
    weak var viewController: GoalsViewController?
    var tabBarItem: UITabBarItem

    init(presenter: UITabBarController) {
        self.presenter = presenter

        tabBarItem = UITabBarItem.goals
    }
}

extension GoalsCoordinator: DashboardResumableCoordinator {
    func resume() {
        guard let viewController = viewController else {
            start()
            return
        }

        viewController.resume()
    }

    public func start() {
        if let presenter = presenter {
            let vc = GoalsViewController()
            viewController = vc
            navigationController = addDashboardPage(presenter: presenter, viewController: vc, tabBarItem: tabBarItem)
            BusyView.shared.hide()
        }
    }
}
