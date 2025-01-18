//
//  AccountCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class AccountCell: UITableViewCell, TableViewElement {
    static var reuseIdentifier: String = "Account"

    @IBOutlet var sectionTitle: UILabel?
    @IBOutlet var accountDetails: UILabel?
    @IBOutlet var providerLogo: ProviderLogoImageView?
    @IBOutlet var clipView: UIView?
    @IBOutlet var accessoryImage: UIImageView?
    @IBOutlet var sectionBackground: UIView?

    @IBOutlet var bottomBorder: NSLayoutConstraint?
    @IBOutlet var bottomSpace: NSLayoutConstraint?

    @IBOutlet var topBorder: NSLayoutConstraint?
    @IBOutlet var sectionTitleSpacing: NSLayoutConstraint?

    @IBOutlet var leftBorder: NSLayoutConstraint?
    @IBOutlet var rightBorder: NSLayoutConstraint?

    @IBOutlet var warningView: WarningBubbleLabel?

    var viewModel: AccountCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()

        if let clipLayer = clipView?.layer {
            clipLayer.cornerRadius = 4.0
            clipLayer.masksToBounds = true
        }
    }

    func bind(account: InstitutionAccount, styles: AppStyles, isLastInSection: Bool, sectionTitle: String?) {
        style(styles: styles)
        viewModel = AccountCellViewModel(view: self, account: account, showBalance: true, styles: styles, isLastInSection: isLastInSection, sectionTitle: sectionTitle)
        accessoryImage?.image = UIImage(systemName: "chevron.right")
    }

    func bind(account: InstitutionAccount, isSelected: Bool, styles: AppStyles, isLastInSection: Bool, sectionTitle: String?) {
        style(styles: styles)
        viewModel = AccountCellViewModel(view: self, account: account, isSelected: isSelected, styles: styles, isLastInSection: isLastInSection, sectionTitle: sectionTitle)
        accessoryImage?.image = UIImage(systemName: "checkmark")
    }

    func bind(account: InstitutionAccount, styles: AppStyles) {
        style(styles: styles)
        viewModel = AccountCellViewModel(view: self, account: account, showBalance: true, styles: styles, isLastInSection: true, sectionTitle: "")
        accessoryImage?.image = .none
        sectionBackground?.isHidden = true
        leftBorder?.constant = 20.0
        rightBorder?.constant = 20.0
        set(sectionTitle: nil)
        topBorder?.constant = 20.0
    }
}

extension AccountCell: Stylable {
    func apply(styles: AppStyles) {
        clipView?.backgroundColor = styles.colors.cells.account.background.color
        accessoryImage?.tintColor = styles.colors.cells.account.accessory.color
        sectionTitle?.font = styles.fonts.sansSerif.headline
        sectionTitle?.textColor = styles.colors.cells.account.sectionTitle.color
    }
}

extension AccountCell: AccountCellViewProtocol {
    func set(roundedCorners: CACornerMask) {
        if let backgroundLayer = sectionBackground?.layer {
            backgroundLayer.cornerRadius = 8.0
            backgroundLayer.masksToBounds = true
            backgroundLayer.maskedCorners = roundedCorners
        }
    }

    func set(accountDescription: NSAttributedString?) {
        accountDetails?.attributedText = accountDescription
    }

    func set(providerLogoURL: URL?) {
        providerLogo?.imageURL = providerLogoURL
    }

    func set(isSelected: Bool) {
        accessoryImage?.alpha = isSelected ? 1.0 : 0.0
    }

    func set(accessibilityIdentifier: String?) {
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    func set(sectionTitle: String?) {
        self.sectionTitle?.text = sectionTitle

        if sectionTitle != nil {
            topBorder?.priority = UILayoutPriority(rawValue: 1.0)
            sectionTitleSpacing?.priority = UILayoutPriority(rawValue: 999.0)
        } else {
            topBorder?.priority = UILayoutPriority(rawValue: 999.0)
            sectionTitleSpacing?.priority = UILayoutPriority(rawValue: 1.0)
        }
    }

    func set(isLastInSection: Bool) {
        bottomBorder?.constant = isLastInSection ? 20.0 : 8.0
        bottomSpace?.constant = isLastInSection ? 8.0 : 0.0
    }

    func set(expiryStatus: ExpiryStatus) {
        switch expiryStatus {
        case .expired:
            warningView?.isHidden = false
            warningView?.fillColor = WarningBubbleLabel.errorColor
        case .expiring:
            warningView?.isHidden = false
            warningView?.fillColor = WarningBubbleLabel.warningColor
        default:
            warningView?.isHidden = true
        }
    }
}
