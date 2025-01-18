//
//  AnyConstraintView.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 05/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public protocol AnyConstraintView {
    func setupSubviews()
    func embedSubviews()
    func setupSubviewsConstraints()
}

public extension AnyConstraintView {
    func setupSubviews() {
        embedSubviews()
        setupSubviewsConstraints()
    }
}
