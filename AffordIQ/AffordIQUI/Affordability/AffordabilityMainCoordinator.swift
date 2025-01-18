//
//  AffordabilityMainCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 14.02.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls

class AffordabilityMainCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var type: AffordabilityMainViewType
    weak var viewController: AffordabilityMainViewController?
    weak var tabBarController: UITabBarController?
    let tabBarItem = UITabBarItem.affordability
    var getStartedType: GetStartedViewType?
    var isDashboard: Bool
    
    init(
        presenter: UINavigationController? = nil,
        type: AffordabilityMainViewType,
        getStartedType: GetStartedViewType? = nil,
        tabBarController: UITabBarController? = nil,
        isDashboard: Bool
    ) {
        self.presenter = presenter
        self.type = type
        self.getStartedType = getStartedType
        self.tabBarController = tabBarController
        self.isDashboard = isDashboard
    }
}

extension AffordabilityMainCoordinator: DashboardResumableCoordinator {
    func resume() {
        guard let viewController = viewController else {
            start()
            return
        }

        viewController.resume()
    }

    public func start() {
        switch type {
        case .tabbar:
            let vc = AffordabilityMainViewController()
            viewController = vc
            if let tabBarController {
                presenter = addDashboardPage(presenter: tabBarController, viewController: vc, tabBarItem: tabBarItem)
            } else {
                presenter = addDashboardPage(presenter: UITabBarController(), viewController: vc, tabBarItem: tabBarItem)
            }
            BusyView.shared.hide()
        default:
            if let presenter = presenter {
                let viewController = AffordabilityMainViewController()
                viewController.bind(type: type, getStartedType: getStartedType, isDashboard: isDashboard)

                presenter.pushViewController(viewController, animated: true)
            }
        }
    }
}
