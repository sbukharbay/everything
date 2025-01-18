//
//  DepositCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 19/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

class DepositCoordinator: NSObject {
    weak var presenter: UINavigationController?
    let targetHeight: CGFloat?
    var showNextButton = false
    var isSettings = false

    init(presenter: UINavigationController, targetHeight: CGFloat?, showNextButton: Bool = false, isSettings: Bool = false) {
        self.presenter = presenter
        self.targetHeight = targetHeight
        self.showNextButton = showNextButton
        self.isSettings = isSettings
    }
}

extension DepositCoordinator: Coordinator {
    func start() {
        if let presenter = presenter, let viewController = DepositViewController.instantiate() {
            viewController.bind(targetHeight: targetHeight,
                                showNextButton: showNextButton,
                                isSettings: isSettings)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
