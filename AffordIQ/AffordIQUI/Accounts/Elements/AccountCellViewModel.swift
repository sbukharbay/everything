//
//  AccountCellViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import Foundation
import UIKit

enum ExpiryStatus {
    case ok
    case expiring
    case expired
}

protocol AccountCellViewProtocol: AnyObject {
    func set(accountDescription: NSAttributedString?)
    func set(providerLogoURL: URL?)
    func set(isSelected: Bool)
    func set(isLastInSection: Bool)
    func set(sectionTitle: String?)
    func set(roundedCorners: CACornerMask)
    func set(accessibilityIdentifier: String?)
    func set(expiryStatus: ExpiryStatus)
}

struct AccountCellViewModel {
    weak var view: AccountCellViewProtocol?

    init(view: AccountCellViewProtocol, account: InstitutionAccount, isSelected: Bool? = nil, showBalance: Bool = false, styles: AppStyles, isLastInSection: Bool, sectionTitle: String?) {
        self.view = view

        let accountDescription = account.describe(showBalance: showBalance, styles: styles)
        view.set(accountDescription: accountDescription)

        let providerLogoURL = URL(string: account.providerLogoUri)
        view.set(providerLogoURL: providerLogoURL)

        if let isSelected = isSelected {
            view.set(isSelected: isSelected)
        }

        view.set(accessibilityIdentifier: "\(account.accountNumber?.sortCode ?? String.missingValuePlaceholder) \(account.accountNumber?.number ?? String.missingValuePlaceholder)")
        view.set(isLastInSection: isLastInSection)
        view.set(sectionTitle: sectionTitle)

        var roundedCorners: CACornerMask = []

        switch (isLastInSection, sectionTitle != nil) {
        case (true, false):
            roundedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case (false, true):
            roundedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case (true, true):
            roundedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        case (false, false):
            break
        }

        if let consent = account.consent {
            if consent.isExpired {
                view.set(expiryStatus: .expired)
            } else if consent.isExpiring {
                view.set(expiryStatus: .expiring)
            } else {
                view.set(expiryStatus: .ok)
            }
        } else {
            view.set(expiryStatus: .ok)
        }

        view.set(roundedCorners: roundedCorners)
    }
}

extension InstitutionAccount {
    func describeBalance(styles: AppStyles = AppStyles.shared) -> NSAttributedString {
        let text = NSMutableAttributedString()
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: styles.fonts.sansSerif.headline,
            .foregroundColor: styles.colors.cells.account.title.color
        ]
        text.append(balance?.currentBalance.description ?? String.missingValuePlaceholder, attributes: titleAttributes)
        return text
    }

    func randomSortCode() -> String {
        let element = { String.randomNumeric(length: 2) }
        return "\(element())-\(element())-\(element())"
    }

    func randomAccountNumber() -> String {
        String.randomNumeric(length: 10)
    }

    func randomDisplayName() -> String {
        "\(String.randomNumeric(length: 3)) \(String.randomNumeric(length: 6)) \(String.randomNumeric(length: 8))"
    }

    func describe(showBalance: Bool = false,
                  showProviderName: Bool = false,
                  showAccountNumber: Bool = false,
                  smallTitles: Bool = false,
                  styles: AppStyles = AppStyles.shared) -> NSAttributedString {
        let text = NSMutableAttributedString()

        let hasAccountNumberAndSortCode = accountNumber?.number != nil && accountNumber?.sortCode != nil
        let accountDetailsFont = hasAccountNumberAndSortCode ? styles.fonts.sansSerif : styles.fonts.redacted
        let titleColor = hasAccountNumberAndSortCode ? styles.colors.cells.account.title.color : styles.colors.text.info.color
        let subtitleColor = hasAccountNumberAndSortCode ? styles.colors.cells.account.detail.color : styles.colors.text.info.color

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: smallTitles ? styles.fonts.sansSerif.footnote : accountDetailsFont.headline,
            .foregroundColor: titleColor
        ]

        let balanceAttributes: [NSAttributedString.Key: Any] = [
            .font: smallTitles ? styles.fonts.sansSerif.footnote : styles.fonts.sansSerif.headline,
            .foregroundColor: styles.colors.cells.account.title.color
        ]

        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: smallTitles ? styles.fonts.sansSerif.footnote : accountDetailsFont.subheadline,
            .foregroundColor: subtitleColor
        ]

        let providerNameAttributes: [NSAttributedString.Key: Any] = [
            .font: smallTitles ? styles.fonts.sansSerif.footnote : styles.fonts.sansSerif.subheadline,
            .foregroundColor: styles.colors.cells.account.detail.color
        ]

        text.append(displayName ?? randomDisplayName(), attributes: titleAttributes)

        let separator = smallTitles ? " " : String.paragraphBreak

        if showProviderName {
            text.append(separator, attributes: text.trailingAttributes)
            text.append(providerDisplayName, attributes: providerNameAttributes)
        }

        if showAccountNumber {
            text.append(separator, attributes: text.trailingAttributes)
            text.append(accountNumber?.sortCode ?? randomSortCode(), attributes: subtitleAttributes)
            text.append(" ", attributes: subtitleAttributes)
            text.append(accountNumber?.number ?? randomAccountNumber(), attributes: subtitleAttributes)
        }

        if showBalance {
            text.append(separator, attributes: text.trailingAttributes)
            text.append(balance?.currentBalance.description ?? String.missingValuePlaceholder, attributes: balanceAttributes)
        }

        return text
    }
    
    enum AccountInfoField {
        case accountName
        case accountNumber
        case balance
    }
    
    func getData(of field: AccountInfoField) -> NSAttributedString {
        let text = NSMutableAttributedString()
        let styles = AppStyles.shared
        
        switch field {
        case .accountName:
            let hasHolderName = displayName != nil
            let holderNameFont = hasHolderName ? styles.fonts.sansSerif : styles.fonts.redacted
            let holderNameColor = hasHolderName ? styles.colors.cells.account.title.color : styles.colors.text.info.color
            
            let providerNameAttributes: [NSAttributedString.Key: Any] = [
                .font: holderNameFont.headline,
                .foregroundColor: holderNameColor
            ]
            
            text.append(displayName ?? randomDisplayName(), attributes: providerNameAttributes)
        case .accountNumber:
            let hasAccountNumberAndSortCode = accountNumber?.number != nil && accountNumber?.sortCode != nil
            let accountNumberAndSortCodeFont = hasAccountNumberAndSortCode ? styles.fonts.sansSerif : styles.fonts.redacted
            let subtitleColor = hasAccountNumberAndSortCode ? styles.colors.cells.account.detail.color : styles.colors.text.info.color
            
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: accountNumberAndSortCodeFont.subheadline,
                .foregroundColor: subtitleColor
            ]
            
            text.append(accountNumber?.sortCode ?? randomSortCode(), attributes: subtitleAttributes)
            text.append(" ", attributes: subtitleAttributes)
            text.append(accountNumber?.number ?? randomAccountNumber(), attributes: subtitleAttributes)
        case .balance:
            let hasBalance = balance != nil
            let balanceColorFont = hasBalance ? styles.fonts.sansSerif : styles.fonts.redacted
            let balanceColor = hasBalance ? styles.colors.cells.account.title.color : styles.colors.text.info.color
            
            let balanceAttributes: [NSAttributedString.Key: Any] = [
                .font: balanceColorFont.headline,
                .foregroundColor: balanceColor
            ]
            
            text.append(displayName ?? randomDisplayName(), attributes: balanceAttributes)
        }
        
        return text
    }
}
