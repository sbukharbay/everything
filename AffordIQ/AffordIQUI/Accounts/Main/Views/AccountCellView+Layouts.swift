//
//  AccountCellView+Layouts.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 17/11/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

extension AccountCellView: AnyConstraintView {
    func embedSubviews() {
        contentView.addSubview(blurView)
        contentView.addSubview(vStack)
        contentView.addSubview(warning)
        
        vStack.addArrangedSubview(titleTop)
        vStack.addArrangedSubview(wrapper)
        
        wrapper.addSubview(accountCellHStack)
        wrapper.addSubview(logo)
        
        accountCellHStack.addArrangedSubview(accountCredentialsVStack)
        accountCellHStack.addArrangedSubview(chevron)
        
        accountCredentialsVStack.addArrangedSubview(accountName)
        accountCredentialsVStack.addArrangedSubview(bankName)
        accountCredentialsVStack.addArrangedSubview(accountNumber)
        accountCredentialsVStack.addArrangedSubview(balance)
    }
    
    func setupSubviewsConstraints() {
        setBlurViewConstraints()
        setVStackConstraints()
        setLogoConstraints()
        setAccountCellHStackConstraints()
        setWarningConstraints()
        setChevronConstraints()
    }
    
    private func setBlurViewConstraints() {
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setVStackConstraints() {
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    private func setWarningConstraints() {
        NSLayoutConstraint.activate([
            warning.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            warning.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            warning.heightAnchor.constraint(equalToConstant: 36),
            warning.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setLogoConstraints() {
        let width = bounds.width * 0.2
        let height = width
        
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8),
            logo.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 8),
            logo.heightAnchor.constraint(equalToConstant: height),
            logo.widthAnchor.constraint(equalToConstant: width)
        ])
    }
    
    private func setChevronConstraints() {
        NSLayoutConstraint.activate([
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func setAccountCellHStackConstraints() {
        NSLayoutConstraint.activate([
            accountCellHStack.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8),
            accountCellHStack.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 8),
            accountCellHStack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -8),
            accountCellHStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -8)
        ])
    }
}
