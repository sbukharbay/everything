//
//  EmailVerificationCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 29.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class EmailVerificationCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var data: UserRegistrationData

    init(presenter: UINavigationController, data: UserRegistrationData) {
        self.presenter = presenter
        self.data = data
    }
}

extension EmailVerificationCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = EmailVerificationViewController()
            viewController.bind(data: data)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
