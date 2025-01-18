//
//  BottomConstraintManager.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 17/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class BottomConstraintManager: NSObject {
    private var monitoring: Bool = false

    @IBOutlet var bottomConstraint: NSLayoutConstraint?
    @IBOutlet var layoutView: UIView?
    @IBOutlet var viewController: UIViewController?

    public func startMonitoring() {
        guard !monitoring else {
            return
        }

        monitoring = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    public func endMonitoring() {
        monitoring = false

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    private func handleKeyboardEvent(_ notification: Any?, isOpening: Bool) {
        if let notification = notification as? Notification,
           let userInfo = notification.userInfo,
           let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let keyboardBeginFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
           let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
           let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            if keyboardEndFrame.equalTo(keyboardBeginFrame) {
                return
            }

            let options = UIView.AnimationOptions(rawValue: curveValue << 16)

            if isOpening {
                var constant = keyboardEndFrame.height
                if let tabBarControlller = viewController?.tabBarController {
                    constant -= tabBarControlller.tabBar.bounds.size.height
                }
                bottomConstraint?.constant = constant
            } else {
                bottomConstraint?.constant = 0.0
            }

            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: { [weak self] in
                self?.layoutView?.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func keyboardWillShow(_ notification: Any?) {
        handleKeyboardEvent(notification, isOpening: true)
    }

    @objc func keyboardWillHide(_ notification: Any?) {
        handleKeyboardEvent(notification, isOpening: false)
    }
}
