//
//  FormScrollView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 21/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class FormScrollView: UIScrollView {
    @IBInspectable var bottomPadding: CGFloat = 0.0

    override public func willMove(toSuperview _: UIView?) {
        super.willMove(toSuperview: superview)

        if superview == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        }
    }

    private func handleKeyboardEvent(notification: Any?, isOpening: Bool) {
        if let notification = notification as? Notification,
           let userInfo = notification.userInfo,
           let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let keyboardBeginFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
           let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
           let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            if keyboardBeginFrame.equalTo(keyboardEndFrame) {
                return
            }

            let options = UIView.AnimationOptions(rawValue: curveValue << 16)
            var contentInset = self.contentInset
            contentInset.bottom = isOpening ? keyboardEndFrame.height + bottomPadding : 0.0

            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: { [weak self] in

                self?.contentInset = contentInset
                self?.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func keyboardWillShow(_ notification: Any?) {
        handleKeyboardEvent(notification: notification, isOpening: true)
    }

    @objc func keyboardWillHide(_ notification: Any?) {
        handleKeyboardEvent(notification: notification, isOpening: false)
    }
}
