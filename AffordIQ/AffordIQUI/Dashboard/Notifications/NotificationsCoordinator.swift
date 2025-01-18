//
//  NotificationsCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 04.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class NotificationsCoordinator: NSObject {
    weak var presenter: UINavigationController?

    public init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension NotificationsCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = NotificationsViewController()
            viewController.bind()
            presenter.tabBarController?.tabBar.isHidden = true
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
