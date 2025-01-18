//
//  UIView+Pinning.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 23/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public extension UIView {
    func pinToSuperview() {
        if let superview = superview {
            translatesAutoresizingMaskIntoConstraints = false

            topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        }
    }
}
