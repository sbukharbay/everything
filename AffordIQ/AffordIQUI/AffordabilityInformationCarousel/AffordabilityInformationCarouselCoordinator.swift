//
//  AffordabilityInformationCarouselCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 10/12/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class AffordabilityInformationCarouselCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var isDashboard: Bool

    public init(presenter: UINavigationController, isDashboard: Bool = false) {
        self.presenter = presenter
        self.isDashboard = isDashboard
    }
}

extension AffordabilityInformationCarouselCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = AffordabilityInformationCarouselViewController()
            viewController.bind(isDashboard: isDashboard)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
