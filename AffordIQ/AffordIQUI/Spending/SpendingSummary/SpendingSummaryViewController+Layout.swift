//
//  SpendingSummaryViewController+Layout.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11/10/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import UIKit
import AffordIQFoundation

extension SpendingSummaryViewController: AnyConstraintView {
    func embedSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(customNavBar)
        view.addSubview(blurEffectView)
        view.addSubview(whiteBackgroundView)
        
        blurEffectView.contentView.addSubview(titleStackView)
        blurEffectView.contentView.addSubview(averageTotalStackView)
        
        titleStackView.addArrangedSubview(iconImageView)
        titleStackView.addArrangedSubview(headerLabel)
        
        averageTotalStackView.addArrangedSubview(infoLabel)
        averageTotalStackView.addArrangedSubview(averageSpend)
        
        whiteBackgroundView.addSubview(overlayLabel)
        whiteBackgroundView.addSubview(tableView)
        whiteBackgroundView.addSubview(emptyTableLabel)
    }
    
    func setupSubviewsConstraints() {
        setBackgroundImageViewConstraints()
        setBlurEffectViewConstraints()
        setTitleStackViewConstraints()
        setIconImageViewConstraints()
        setAverageTotalStackViewConstraints()
        setWhiteBackgroundViewConstraints()
        setOverlayLabelConstraints()
        setTableViewConstraints()
        setEmptyTableLabelConstraints()
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
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    private func setTitleStackViewConstraints() {
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            titleStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor)
        ])
    }
    
    private func setIconImageViewConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            iconImageView.widthAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setAverageTotalStackViewConstraints() {
        NSLayoutConstraint.activate([
            averageTotalStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 24),
            averageTotalStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            averageTotalStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setWhiteBackgroundViewConstraints() {
        NSLayoutConstraint.activate([
            whiteBackgroundView.topAnchor.constraint(equalTo: averageTotalStackView.bottomAnchor, constant: 24),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setOverlayLabelConstraints() {
        NSLayoutConstraint.activate([
            overlayLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 16),
            overlayLabel.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor)
        ])
    }
    
    private func setTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: overlayLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 24),
            tableView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -24),
            tableView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor)
        ])
    }
    
    private func setEmptyTableLabelConstraints() {
        NSLayoutConstraint.activate([
            emptyTableLabel.centerYAnchor.constraint(equalTo: whiteBackgroundView.centerYAnchor),
            emptyTableLabel.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor),
            emptyTableLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
            emptyTableLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16)
        ])
    }
}
