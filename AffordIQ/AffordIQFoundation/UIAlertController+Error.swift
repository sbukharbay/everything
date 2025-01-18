//
//  UIAlertController+Error.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 22/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public extension UIAlertController {
    static func present(success: String,
                        from viewController: UIViewController?,
                        completion: (() -> Void)? = nil) {
        asyncIfRequired {
            let alertController = UIAlertController(title: nil, message: success, preferredStyle: .alert)
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("OK", bundle: Bundle.main, comment: "OK"),
                              style: .default,
                              handler: { _ in completion?() }))
            viewController?.present(alertController, animated: true)
        }
    }

    static func present(error: Error,
                        from viewController: UIViewController?,
                        completion: (() -> Void)? = nil) {
        asyncIfRequired {
            let errorDescription = (error as? LocalizedError)?.localizedDescription ?? "\(error)"
            #if DEBUG
                let alertController = UIAlertController(
                    title: NSLocalizedString("Error", bundle: Bundle.main, comment: "Error"),
                    message: errorDescription, preferredStyle: .alert
                )
            #else
                let alertController = UIAlertController(
                    title: NSLocalizedString("Sorry", bundle: Bundle.main, comment: "Error"),
                    message: "This service is not available right now. Please try again later.", preferredStyle: .alert
                )
            #endif
            
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("OK", bundle: Bundle.main, comment: "OK"),
                              style: .default,
                              handler: { _ in completion?() }))
            viewController?.present(alertController, animated: true)
        }
    }
}
