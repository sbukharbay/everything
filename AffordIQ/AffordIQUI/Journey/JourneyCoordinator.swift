//
//  JourneyCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 05/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit

public class JourneyCoordinator: NSObject {
    weak var presenter: UINavigationController?

    public init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension JourneyCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = JourneyViewController()
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
