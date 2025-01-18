//
//  SetAGoalCheckPointCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 01/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class SetAGoalCheckPointCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var type: SetAGoalCheckPointViewType
    var getStartedType: GetStartedViewType?

    init(presenter: UINavigationController, type: SetAGoalCheckPointViewType, getStartedType: GetStartedViewType? = nil) {
        self.presenter = presenter
        self.type = type
        self.getStartedType = getStartedType
    }
}

extension SetAGoalCheckPointCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = SetAGoalCheckPointViewController()
            viewController.bind(goalType: type, getStartedType: getStartedType)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
