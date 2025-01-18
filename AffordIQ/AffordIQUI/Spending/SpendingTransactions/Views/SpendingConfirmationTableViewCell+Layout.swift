//
//  SpendingConfirmationTableViewCell+Layout.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbayv on 06/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

extension SpendingConfirmationTableViewCell: AnyConstraintView {
    func embedSubviews() {
        contentView.addSubview(content)
    }
    
    func setupSubviewsConstraints() {
        content.embedToView(contentView)
    }
}
