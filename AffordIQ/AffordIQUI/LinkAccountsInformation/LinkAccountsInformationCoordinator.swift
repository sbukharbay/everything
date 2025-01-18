//
//  LinkAccountsInformationCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 22/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class LinkAccountsInformationCoordinator: NSObject {
    weak var presenter: UINavigationController?

    public init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension LinkAccountsInformationCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = LinkAccountsInformationViewController()
            viewController.bind()

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
