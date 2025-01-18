//
//  FeedbackCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 26.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class FeedbackCoordinator: NSObject {
    weak var presenter: UINavigationController?
    
    public init(presenter: UINavigationController) {
        self.presenter = presenter
    }
}

extension FeedbackCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = FeedbackViewController()
            viewController.bind()
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
