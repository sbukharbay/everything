//
//  SetAGoalCheckPointViewController+Layout.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 06/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

extension SetAGoalCheckPointViewController: AnyConstraintView {
    func embedSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(customNavBar)
        view.addSubview(blurEffectView)
        
        blurEffectView.contentView.addSubview(titleStackView)
        blurEffectView.contentView.addSubview(tableView)
        
        titleStackView.addSubview(titleIconImage)
        titleStackView.addSubview(headerLabel)
    }
    
    func setupSubviewsConstraints() {
        setBackgroundImageViewConstraints()
        setBlurEffectViewConstraints()
        setTitleStackViewConstraints()
        setTableViewConstraints()
        setTitleIconImageConstraints()
        setHeaderLabelConstraints()
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
    
    private func setBlurEffectViewConstraints() {
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    private func setTitleStackViewConstraints() {
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            titleStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor)
        ])
    }
    
    private func setTitleIconImageConstraints() {
        NSLayoutConstraint.activate([
            titleIconImage.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor),
            titleIconImage.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor, constant: -2),
            titleIconImage.trailingAnchor.constraint(equalTo: headerLabel.leadingAnchor, constant: -8),
            titleIconImage.heightAnchor.constraint(equalToConstant: 30),
            titleIconImage.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setHeaderLabelConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: titleStackView.topAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: titleStackView.bottomAnchor)
        ])
    }
    
    private func setTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleStackView.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -24)
        ])
    }
}
