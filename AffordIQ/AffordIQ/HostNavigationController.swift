//
//  HostNavigationController.swift
//  AffordIQ
//
//  Created by Sultangazy Bukharbay on 28/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQAuth0
import AffordIQControls
import AffordIQFoundation
import AffordIQUI
import UIKit

class HostNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barStyle = .black
        
        let bundle = Bundle(for: type(of: self))
        Environment.setup(bundle: bundle)
        
        let appStyles = AppStyles.shared
        
        let imageView = UIImageView(frame: view.bounds)
        imageView.tintColor = UIColor.white
        imageView.image = UIImage(named: "logo_release")
        imageView.frame.size.height = 220
        imageView.frame.size.width = 220
        imageView.center = CGPoint(x: view.center.x, y: view.center.y - 80.5)
        imageView.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor(hex: "120A35")
        view.addSubview(imageView)
        
        Task {
            let isInMaintenanceMode = await FirebaseDBManager.shared.isInMaintenanceMode
            
            if isInMaintenanceMode {
                let maintenanceVC = MaintenanceModeViewController(styles: appStyles)
                self.setViewControllers([maintenanceVC], animated: false)
            } else {
                let rootCoordinator = RootCoordinator()
                rootCoordinator.start()
            }
            
            UIView.animate(withDuration: 0.5) {
                imageView.alpha = 0.0
            } completion: { _ in
                imageView.removeFromSuperview()
            }
        }
    }
}
