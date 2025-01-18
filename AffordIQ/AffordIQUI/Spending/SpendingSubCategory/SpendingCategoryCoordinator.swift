//
//  SpendingSubCategoryCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 27/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

public class SpendingCategoryCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var completion: (ChildCategoriesModel) -> Void

    init(presenter: UINavigationController, completion: @escaping ((ChildCategoriesModel) -> Void)) {
        self.presenter = presenter
        self.completion = completion
    }
}

extension SpendingCategoryCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = SpendingCategoryViewController()
            viewController.bind(completion: completion)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
