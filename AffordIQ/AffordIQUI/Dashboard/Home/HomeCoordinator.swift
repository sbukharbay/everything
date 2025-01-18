//
//  HomeCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 29.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls

class HomeCoordinator: NSObject {
    weak var presenter: UITabBarController?
    weak var navigationController: UINavigationController?
    weak var viewController: HomeViewController?
    var tabBarItem: UITabBarItem
    
    init(presenter: UITabBarController) {
        self.presenter = presenter
        
        tabBarItem = UITabBarItem.home
    }
}

extension HomeCoordinator: DashboardResumableCoordinator {
    func resume() {
        guard let viewController = viewController else {
            start()
            return
        }
        viewController.resume()
    }

    public func start() {
        if let presenter = presenter {
            let vc = HomeViewController()
            viewController = vc
            navigationController = addDashboardPage(
                presenter: presenter,
                viewController: vc,
                tabBarItem: tabBarItem
            )
            BusyView.shared.hide()
        }
    }
}
