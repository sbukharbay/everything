//
//  LinkAccountsVideoCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 01/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class LinkAccountsVideoCoordinator: NSObject {
    weak var presenter: UINavigationController?

    public init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension LinkAccountsVideoCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = LinkAccountsVideoViewController()
            viewController.bind()

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
