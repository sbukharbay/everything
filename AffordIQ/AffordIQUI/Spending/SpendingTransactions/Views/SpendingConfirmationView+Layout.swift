//
//  SpendingConfirmationView+Layout.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 05/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

extension SpendingConfirmationView: AnyConstraintView {
    func embedSubviews() {
        addSubview(container)
        container.addSubview(hStackView)
        
        merchantVStack.addArrangedSubview(merchantLabel)
        merchantVStack.addArrangedSubview(paymentDateLabel)
        
        hStackView.addArrangedSubview(merchantVStack)
        hStackView.addArrangedSubview(costLabel)
    }
    
    func setupSubviewsConstraints() {
        setBackgroundWrapViewConstraints()
        setBackgroundStackViewConstraints()
    }
    
    private func setBackgroundWrapViewConstraints() {
        container.embedToView(self, padding: 4)
    }
    
    private func setBackgroundStackViewConstraints() {
        hStackView.embedToView(container, padding: 12)
    }
}
