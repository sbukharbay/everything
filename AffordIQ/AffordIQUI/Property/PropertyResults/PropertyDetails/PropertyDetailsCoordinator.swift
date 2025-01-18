//
//  PropertyDetailsCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 07/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import SafariServices
import UIKit

class PropertyDetailsCoordinator: NSObject {
    weak var presenter: UINavigationController?
    let listing: Listing

    init(presenter: UINavigationController, listing: Listing) {
        self.presenter = presenter
        self.listing = listing
    }
}

extension PropertyDetailsCoordinator: Coordinator {
    func start() {
        if let presenter = presenter,
           let detailsUrl = URL(string: listing.detailsUrl) {
            let viewController = SFSafariViewController(url: detailsUrl)
            viewController.loadViewIfNeeded()
            viewController.view.accessibilityIdentifier = "PropertyDetails"
            presenter.present(viewController, animated: true, completion: nil)
        }
    }
}
