//
//  TermsCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 13/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit

public class TermsCoordinator: NSObject {
    weak var presenter: UINavigationController?

    public init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension TermsCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = TermsViewController()
            viewController.bind()
            
            presenter.setViewControllers([viewController], animated: true)
        }
    }
}
