//
//  CheckYourEmailCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 01.12.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class CheckYourEmailCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var data: UserRegistrationData

    init(presenter: UINavigationController, data: UserRegistrationData) {
        self.presenter = presenter
        self.data = data
    }
}

extension CheckYourEmailCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = CheckYourEmailViewController()
            viewController.bind(data: data)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
