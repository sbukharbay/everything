//
//  MilestoneInformationCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 09/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class MilestoneInformationCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var type: CarouselViewType

    public init(presenter: UINavigationController, type: CarouselViewType) {
        self.presenter = presenter
        self.type = type
    }
}

extension MilestoneInformationCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = MilestoneInformationViewController()
            viewController.bind(type: type)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
