//
//  RegistrationCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 22/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit
import AffordIQFoundation

class RegistrationCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var registrationData: UserRegistrationData?
    var isSettings = false

    init(presenter: UINavigationController, data: UserRegistrationData? = nil, isSettings: Bool = false) {
        self.presenter = presenter
        registrationData = data
        self.isSettings = isSettings
    }
}

extension RegistrationCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter, let viewController = RegistrationViewController.instantiate() {
            viewController.bind(data: registrationData, isSettings: isSettings)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
