//
//  SavingBudgetViewController+Layout.swift
//  AffordIQUI
//
//  Created by Asilbek Djamaldinov on 07/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

extension SavingBudgetViewController: AnyConstraintView {
    func embedSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(customNavBar)
        view.addSubview(blurEffectView)
        view.addSubview(overlayView)
        
        blurEffectView.contentView.addSubview(titleStackView)
        blurEffectView.contentView.addSubview(circleMeterView)
        blurEffectView.contentView.addSubview(meterLabelStackView)
        blurEffectView.contentView.addSubview(additionalSavingsStackView)
        blurEffectView.contentView.addSubview(depositSavingsStackView)
        
        overlayView.addSubview(whiteBackround)
        overlayView.addSubview(tableView)
        overlayView.addSubview(emptyTableDescription)
        
        titleStackView.addArrangedSubview(iconImageView)
        titleStackView.addArrangedSubview(headerLabel)
        
        meterLabelStackView.addArrangedSubview(monthsLabel)
        meterLabelStackView.addArrangedSubview(untilAffordableLabel)
        
        additionalSavingsStackView.addArrangedSubview(additionalSavingsLabel)
        additionalSavingsStackView.addArrangedSubview(additionalSavingsAmountLabel)
    }
    
    func setupSubviewsConstraints() {
        setBackgroundImageViewConstraints()
        setBlurEffectViewConstraints()
        setTitleStackViewConstraints()
        setCircleMeterViewConstraints()
        setMeterLabelStackViewConstraints()
        setAdditionalSavingsStackViewConstraints()
        setDepositSavingsStackViewConstraints()
        setOverlayViewConstraints()
        setWhiteBackroundConstraints()
        setWhiteOverlayStackViewConstraints()
        setEmptyTableDescriptionConstraints()
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
            blurEffectView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33)
        ])
    }
    
    private func setTitleStackViewConstraints() {
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            titleStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor)
        ])
    }
    
    private func setCircleMeterViewConstraints() {
        NSLayoutConstraint.activate([
            circleMeterView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 24),
            circleMeterView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 24),
            circleMeterView.heightAnchor.constraint(equalTo: blurEffectView.heightAnchor, multiplier: 0.5),
            circleMeterView.widthAnchor.constraint(equalTo: blurEffectView.heightAnchor, multiplier: 0.5)
        ])
    }
    
    private func setMeterLabelStackViewConstraints() {
        NSLayoutConstraint.activate([
            meterLabelStackView.centerXAnchor.constraint(equalTo: circleMeterView.centerXAnchor),
            meterLabelStackView.centerYAnchor.constraint(equalTo: circleMeterView.centerYAnchor),
            meterLabelStackView.leadingAnchor.constraint(equalTo: circleMeterView.leadingAnchor, constant: 8),
            meterLabelStackView.trailingAnchor.constraint(equalTo: circleMeterView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setAdditionalSavingsStackViewConstraints() {
        NSLayoutConstraint.activate([
            additionalSavingsStackView.centerYAnchor.constraint(equalTo: circleMeterView.centerYAnchor),
            additionalSavingsStackView.leadingAnchor.constraint(equalTo: circleMeterView.trailingAnchor, constant: 16),
            additionalSavingsStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setDepositSavingsStackViewConstraints() {
        NSLayoutConstraint.activate([
            depositSavingsStackView.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -24),
            depositSavingsStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 24),
            depositSavingsStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24)
        ])
    }
    
    private func setOverlayViewConstraints() {
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: blurEffectView.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setWhiteOverlayStackViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 25),
            tableView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 24),
            tableView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -24),
            tableView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor)
        ])
    }
    
    private func setWhiteBackroundConstraints() {
        NSLayoutConstraint.activate([
            whiteBackround.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 75),
            whiteBackround.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            whiteBackround.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            whiteBackround.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setEmptyTableDescriptionConstraints() {
        NSLayoutConstraint.activate([
            emptyTableDescription.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 25),
            emptyTableDescription.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 24),
            emptyTableDescription.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -24),
            emptyTableDescription.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -25),
            emptyTableDescription.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            emptyTableDescription.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
        ])
    }
}
