//
//  ExternalCapitalCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 19/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class ExternalCapitalCoordinator: NSObject {
    weak var presenter: UINavigationController?
    let targetHeight: CGFloat?
    let externalCapital: ExternalCapitalResponse?
    
    init(presenter: UINavigationController, targetHeight: CGFloat?, externalCapital: ExternalCapitalResponse?) {
        self.presenter = presenter
        self.targetHeight = targetHeight
        self.externalCapital = externalCapital
    }
}

extension ExternalCapitalCoordinator: Coordinator {
    func start() {
        if let presenter = presenter,
           let viewController = ExternalCapitalViewController.instantiate() {
            viewController.bind(targetHeight: targetHeight, externalCapital: externalCapital)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
