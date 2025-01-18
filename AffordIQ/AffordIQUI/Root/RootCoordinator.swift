//
//  RootCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 28/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import UIKit
import AffordIQFoundation

public class RootCoordinator: NSObject {
    
}

extension RootCoordinator: Coordinator {
    public func start() {
        if let root = RootViewController.instantiate(),
           let window = UIApplication.shared.windows.first {
            root.bind()
            
            let navigationController = UINavigationController()
            navigationController.setNavigationBarHidden(true, animated: false)
            navigationController.navigationBar.style(styles: AppStyles.shared)
            
            let imageView = AppStyles.shared.backgroundImages.defaultImage.imageView
            imageView.frame = navigationController.view.bounds
            navigationController.view.insertSubview(imageView, at: 0)
            
            window.rootViewController = navigationController
            window.overrideUserInterfaceStyle = .light
            window.makeKeyAndVisible()
            
            navigationController.setViewControllers([root], animated: false)
        }
    }
}
