//
//  AccountsViewController+Layouts.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 16/11/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

extension AccountsViewController: AnyConstraintView {
    func embedSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(customNavBar)
        view.addSubview(tableView)
        view.addSubview(buttonContainerView)
        
        buttonContainerView.addSubview(buttonVStack)
        
        buttonVStack.addArrangedSubview(reconsentButton)
        buttonVStack.addArrangedSubview(addAccountsButton)
    }
    
    func setupSubviewsConstraints() {
        setBackgroundImageViewConstraints()
        setTableViewConstraints()
        setButtonContainerViewConstraints()
        setButtonVStackConstraints()
    }
    
    func setCustomNavBarConstraints() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }
    
    private func setBackgroundImageViewConstraints() {
        backgroundImageView.embedToView(view)
    }
    
    private func setTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor)
        ])
    }
    
    private func setButtonContainerViewConstraints() {
        NSLayoutConstraint.activate([
            buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setButtonVStackConstraints() {
        NSLayoutConstraint.activate([
            buttonVStack.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 8),
            buttonVStack.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: 24),
            buttonVStack.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor, constant: -24),
            buttonVStack.bottomAnchor.constraint(equalTo: buttonContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
}
