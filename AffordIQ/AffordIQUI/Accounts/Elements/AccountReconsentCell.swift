//
//  AccountReconsentCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11/08/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls
import AffordIQFoundation

protocol AccountReconsentCellDelegate: AnyObject {
    func onReconsentButtonClick(_ cell: UITableViewCell)
}

class AccountReconsentCell: UITableViewCell {
    
    weak var delegate: AccountReconsentCellDelegate?
    
    private(set) lazy var renewButton: UIButton = {
        var view = UIButton()
        view.backgroundColor = .black
        view.setTitle("Renew Consent", for: .normal)
        view.tintColor = .white
        view.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        view.layer.cornerRadius = 8
        view.addTarget(self, action: #selector(handleRenewButtonClick), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    func configure() {
        contentView.addSubview(renewButton)
        
        NSLayoutConstraint.activate([
            renewButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            renewButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            renewButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            renewButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            renewButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    
    // MARK: - Actions
    @objc func handleRenewButtonClick() {
        delegate?.onReconsentButtonClick(self)
    }
}
