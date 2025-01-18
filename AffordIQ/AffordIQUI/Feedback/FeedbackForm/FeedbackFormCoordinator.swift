//
//  FeedbackFormCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 28.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class FeedbackFormCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var className: String

    public init(presenter: UINavigationController, className: String) {
        self.presenter = presenter
        self.className = className
    }
}

extension FeedbackFormCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = FeedbackFormViewController()
            viewController.bind(className: className)
            
            let transition = CATransition()
            transition.type = .push
            transition.subtype = .fromLeft
            presenter.view.layer.add(transition, forKey: nil)
            presenter.pushViewController(viewController, animated: false)
        }
    }
}
