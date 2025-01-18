//
//  StateLoaderCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 20.01.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit

public class StateLoaderCoordinator: NSObject {
    weak var presenter: UINavigationController?

    public init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension StateLoaderCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = StateLoaderViewController()
            viewController.bind()
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
