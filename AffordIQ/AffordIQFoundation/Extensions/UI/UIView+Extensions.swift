//
//  UIView+Extensions.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 28/07/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public extension UIView {
    static var identifier: String {
        String(describing: self)
    }
}

// MARK: - Constraints
public extension UIView {
    func embedToView(_ view: UIView, padding: CGFloat = 0) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding)
        ])
    }
}
