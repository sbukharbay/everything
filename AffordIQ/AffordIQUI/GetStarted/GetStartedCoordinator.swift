//
//  GetStartedCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.10.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit

public class GetStartedCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var type: GetStartedViewType

    public init(presenter: UINavigationController, type: GetStartedViewType) {
        self.presenter = presenter
        self.type = type
    }
}

extension GetStartedCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = GetStartedViewController()
            viewController.bind(type: type)
            presenter.tabBarController?.tabBar.isHidden = true
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
