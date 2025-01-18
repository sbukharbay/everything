//
//  SpendingConfirmationViewController+Layout.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 05/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

extension SpendingConfirmationViewController: AnyConstraintView {
    func embedSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(customNavBar)
        view.addSubview(blurEffectViewTop)
        view.addSubview(blurEffectViewBottom)
        
        blurEffectViewTop.contentView.addSubview(titleStackView)
        blurEffectViewTop.contentView.addSubview(informationLabel)
        blurEffectViewTop.contentView.addSubview(categoryStackView)
        blurEffectViewTop.contentView.addSubview(currentTransaction)
        
        blurEffectViewBottom.contentView.addSubview(tableViewBottom)
        blurEffectViewBottom.contentView.addSubview(remainingSetsLabel)
        
        titleStackView.addArrangedSubview(iconImageView)
        titleStackView.addArrangedSubview(headerLabel)
        
        categoryStackView.addArrangedSubview(categoryLabel)
        categoryStackView.addArrangedSubview(confirmButtonStackView)
        
        confirmButtonStackView.addArrangedSubview(yesButton)
        confirmButtonStackView.addArrangedSubview(pikeLabel)
        confirmButtonStackView.addArrangedSubview(noButton)
    }
    
    func setupSubviewsConstraints() {
        setBackgroundImageViewConstraints()
        setBlurEffectViewTopConstraints()
        setTitleStackViewConstraints()
        setInformationLabelConstraints()
        setConfirmButtonStackViewConstraints()
        setCategoryStackViewConstraints()
        setTableViewTopConstraints()
        setRemainingSetsLabelConstraints()
        setBlurEffectViewBottomConstraints()
        setTableViewBottomConstraints()
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
    
    private func setBlurEffectViewTopConstraints() {
        // Temporary height. After data is loaded this constraint is deactivated
        blurTopEffectHeightConstraint = blurEffectViewTop.heightAnchor.constraint(equalToConstant: 240)
        NSLayoutConstraint.activate([
            blurEffectViewTop.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectViewTop.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectViewTop.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurTopEffectHeightConstraint
        ])
    }
    
    private func setTitleStackViewConstraints() {
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: blurEffectViewTop.contentView.topAnchor, constant: 24),
            titleStackView.centerXAnchor.constraint(equalTo: blurEffectViewTop.contentView.centerXAnchor)
        ])
    }
    
    private func setInformationLabelConstraints() {
        NSLayoutConstraint.activate([
            informationLabel.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 16),
            informationLabel.leadingAnchor.constraint(equalTo: blurEffectViewTop.contentView.leadingAnchor, constant: 24),
            informationLabel.trailingAnchor.constraint(equalTo: blurEffectViewTop.contentView.trailingAnchor, constant: -24)
        ])
    }
    
    private func setConfirmButtonStackViewConstraints() {
        NSLayoutConstraint.activate([
            confirmButtonStackView.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setCategoryStackViewConstraints() {
        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 16),
            categoryStackView.leadingAnchor.constraint(equalTo: blurEffectViewTop.leadingAnchor, constant: 24),
            categoryStackView.trailingAnchor.constraint(equalTo: blurEffectViewTop.trailingAnchor, constant: -24)
        ])
    }
    
    private func setTableViewTopConstraints() {
        NSLayoutConstraint.activate([
            currentTransaction.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 8),
            currentTransaction.leadingAnchor.constraint(equalTo: blurEffectViewTop.leadingAnchor, constant: 16),
            currentTransaction.trailingAnchor.constraint(equalTo: blurEffectViewTop.trailingAnchor, constant: -16),
            currentTransaction.bottomAnchor.constraint(equalTo: blurEffectViewTop.bottomAnchor, constant: -16)
        ])
    }
    
    private func setBlurEffectViewBottomConstraints() {
        NSLayoutConstraint.activate([
            blurEffectViewBottom.topAnchor.constraint(equalTo: blurEffectViewTop.bottomAnchor, constant: 16),
            blurEffectViewBottom.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectViewBottom.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectViewBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    private func setRemainingSetsLabelConstraints() {
        NSLayoutConstraint.activate([
            remainingSetsLabel.topAnchor.constraint(equalTo: blurEffectViewBottom.topAnchor, constant: 16),
            remainingSetsLabel.centerXAnchor.constraint(equalTo: blurEffectViewBottom.centerXAnchor)
        ])
    }
    
    private func setTableViewBottomConstraints() {
        NSLayoutConstraint.activate([
            tableViewBottom.topAnchor.constraint(equalTo: remainingSetsLabel.bottomAnchor, constant: 16),
            tableViewBottom.leadingAnchor.constraint(equalTo: blurEffectViewBottom.leadingAnchor, constant: 16),
            tableViewBottom.trailingAnchor.constraint(equalTo: blurEffectViewBottom.trailingAnchor, constant: -16),
            tableViewBottom.bottomAnchor.constraint(equalTo: blurEffectViewBottom.bottomAnchor, constant: 0)
        ])
    }
    
    func deactivateBlurHeightConstraint() {
        blurTopEffectHeightConstraint.isActive = false
    }
}
