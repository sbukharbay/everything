//
//  ReconsentProcessingCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 01.08.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

public class ReconsentProcessingCoordinator: NSObject {
    weak var presenter: UINavigationController?
    var providers: ReconsentRequestModel
    var type: PreReconsentType
    
    public init(presenter: UINavigationController, providers: ReconsentRequestModel, preReconsentType: PreReconsentType? = nil) {
        self.presenter = presenter
        self.providers = providers
        self.type = preReconsentType ?? .reconsent
    }
}

extension ReconsentProcessingCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = ReconsentProcessingViewController()
            viewController.bind(providers: providers, preReconsentType: type)
            presenter.pushViewController(viewController, animated: true)
        }
    }
}
