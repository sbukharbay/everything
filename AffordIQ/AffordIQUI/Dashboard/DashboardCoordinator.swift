//
//  DashboardCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 22/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import Combine
import UIKit
import AffordIQAuth0

class DashboardCoordinator: NSObject {
    static let logoutRequested = Notification.Name("com.blackarrow.logoutRequested")

    weak var presenter: UINavigationController?
    let session: SessionType

    init(presenter: UINavigationController, session: SessionType = Auth0Session.shared) {
        self.presenter = presenter

        session.isOnboardingCompleted = true
        self.session = session
    }
}

extension DashboardCoordinator: Coordinator {
    func start() {
        if let presenter = presenter,
           let viewController = DashboardViewController.instantiate() {
            
            BusyView.shared.show(
                navigationController: presenter,
                title: NSLocalizedString("Connecting", bundle: uiBundle, comment: "Connecting"),
                subtitle: NSLocalizedString("Retrieving your account details...", comment: "Retrieving your account details..."),
                styles: AppStyles.shared) {
                    viewController.bind()
                    presenter.setViewControllers([viewController], animated: true)
            }
        }
    }
}

protocol DashboardBindable {
    func bind(styles: AppStyles)
}

func addDashboardPage(presenter: UITabBarController, viewController: UIViewController & DashboardBindable, tabBarItem: UITabBarItem) -> UINavigationController {
    let navigationController = UINavigationController()
    navigationController.setViewControllers([viewController], animated: false)
    navigationController.tabBarItem = tabBarItem
    navigationController.navigationBar.style(styles: AppStyles.shared)

    let imageView = AppStyles.shared.backgroundImages.defaultImage.imageView
    imageView.frame = navigationController.view.bounds
    navigationController.view.insertSubview(imageView, at: 0)

    viewController.bind(styles: AppStyles.shared)

    var viewControllers = presenter.viewControllers ?? []
    viewControllers.append(navigationController)
    presenter.viewControllers = viewControllers

    return navigationController
}
