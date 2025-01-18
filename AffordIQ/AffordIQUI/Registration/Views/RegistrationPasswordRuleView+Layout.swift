//
//  RegistrationPasswordRuleView+Layout.swift
//  AffordIQUI
//
//  Created by Asilbek Djamaldinov on 28/07/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

extension RegistrationPasswordRuleView {
    func setStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setIconConstraints() {
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 16),
            icon.widthAnchor.constraint(equalToConstant: 16)
        ])
    }
}
