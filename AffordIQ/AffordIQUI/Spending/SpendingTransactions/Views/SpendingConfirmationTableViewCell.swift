//
//  SpendingConfirmationTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 06/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class SpendingConfirmationTableViewCell: NiblessTableViewCell, Stylable {
    private(set) lazy var content: SpendingConfirmationView = {
        let view = SpendingConfirmationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        contentView.layer.cornerRadius = 5
        
        setupSubviews()
        content.setupSubviews()
    }
}
