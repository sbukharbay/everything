//
//  BusyView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 02/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

public class BusyView: NSObject {
    @IBOutlet var title: UILabel?
    @IBOutlet var subtitle: UILabel?
    @IBOutlet var background: BackgroundImageView?
    @IBOutlet var activity: UIActivityIndicatorView?
    @IBOutlet var image: UIImageView?

    public private(set) var isPresented = false
    weak var view: UIView?
    
    public func show(navigationController: UINavigationController, title: String = "", subtitle: String = "", styles: AppStyles = AppStyles.shared, fullScreen: Bool = true, completion: (() -> Void)? = nil) {
        let nibName = fullScreen ? "BusyView" : "BusyOverlay"
        let titleFont = fullScreen ? styles.fonts.sansSerif.largeTitle : styles.fonts.sansSerif.title2

        let nib = UINib(nibName: nibName, bundle: Bundle(for: BusyView.self))
        let nibObjects = nib.instantiate(withOwner: self, options: [:])
        
        isPresented = true
        
        if let view = nibObjects.first(where: { $0 is UIView }) as? UIView {
            view.frame = UIScreen.main.bounds
            view.alpha = 0.0
            navigationController.view.superview?.addSubview(view)

            background?.apply(styles: styles)

            self.title?.text = title
            self.subtitle?.text = subtitle

            self.title?.font = titleFont
            self.subtitle?.font = styles.fonts.sansSerif.title3

            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: { view.alpha = 1.0 }, completion: { _ in completion?() })
            self.view = view
        }
    }

    public func hide(success: Bool? = nil) {
        if let view = view {
            let fade: (TimeInterval) -> Void = { delay in
                UIView.animate(withDuration: 0.25, delay: delay, animations: { view.alpha = 0.0 }, completion: { _ in view.removeFromSuperview() })
            }
            asyncIfRequired { [weak self] in

                if let success = success,
                   let image = self?.image,
                   let activity = self?.activity {
                    let imageName = success ? "checkmark.circle.fill" : "x.circle.fill"
                    image.image = UIImage(systemName: imageName)
                    image.isHidden = false
                    image.alpha = 0.0

                    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                        activity.alpha = 0.0
                        image.alpha = 1.0
                    }, completion: nil)

                    fade(1)
                } else {
                    fade(0)
                }
            }
            
            isPresented = false
        }
    }

    public static var shared: BusyView = .init()
}
