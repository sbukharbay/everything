//
//  HelpAndSupportCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 15/08/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

class HelpAndSupportCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var isTerms: Bool

    init(presenter: UINavigationController, isTerms: Bool = false) {
        self.presenter = presenter
        self.isTerms = isTerms
    }
}

extension HelpAndSupportCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = HelpAndSupportViewController()
            viewController.bind(isTerms: isTerms)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
