//
//  SetAGoalCheckPointTableViewFooter.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 07/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls
import AffordIQFoundation

class SetAGoalCheckPointTableViewFooter: UITableViewHeaderFooterView, Stylable {
    private(set) lazy var goalsSetLabel: TitleLabelBlue = {
        let view = TitleLabelBlue()
        view.text = "Your goal is set."
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    func setup() {
        contentView.addSubview(goalsSetLabel)
        NSLayoutConstraint.activate([
            goalsSetLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            goalsSetLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
