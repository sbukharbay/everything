//
//  AccountCellView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 17/11/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation
import AffordIQControls
import SVGKit

class AccountCellView: NiblessTableViewCell {
    private(set) lazy var wrapper: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var vStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var titleTop: HeadingTitleLabel = {
        let view = HeadingTitleLabel()
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var logo: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var accountName: FieldLabelBoldLight = {
        let view = FieldLabelBoldLight()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var bankName: StandardLabel = {
        let view = StandardLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var accountNumber: StandardLabel = {
        let view = StandardLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var balance: FieldLabelBoldLight = {
        let view = FieldLabelBoldLight()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var accountCredentialsVStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var accountCellHStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var chevron: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "chevron.right")
        
        return view
    }()
    
    private(set) lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var warning: WarningBubbleLabel = {
        let view = WarningBubbleLabel()
        view.text = "!"
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
        
        // Configure backgroup caller, creating blur effect
        self.backgroundColor = .clear
    }
    
    func configureAccountCell(_ account: InstitutionAccount, header: String? = nil) {
        // Configure styles of Labels
        style(styles: AppStyles.shared)
        
        // Configure cell's data
        titleTop.text = header
        titleTop.isHidden = header == nil
        
        accountName.attributedText = account.getData(of: .accountName)
        bankName.text = account.providerDisplayName
        accountNumber.attributedText = account.getData(of: .accountNumber)
        balance.attributedText = account.getData(of: .balance)
        
        // TODO: Refactor
        if let consent = account.consent {
            if consent.isExpired {
                set(expiryStatus: .expired)
            } else if consent.isExpiring {
                set(expiryStatus: .expiring)
            } else {
                set(expiryStatus: .ok)
            }
        } else {
            set(expiryStatus: .ok)
        }
        
        downloadLogo(of: account)
    }
    
    @MainActor
    func downloadLogo(of account: InstitutionAccount) {
        Task {
            let image = await ImageDownloader.shared.getImage(urlString: account.providerLogoUri)
            logo.image = image
        }
    }
    
    func configureShape(position: AccountPosition) {
        layer.cornerRadius = 16
        clipsToBounds = true
        
        switch position {
        case .top: layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            wrapper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        case .single:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            wrapper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        default: layer.maskedCorners = []
        }
    }
    
    func set(expiryStatus: ExpiryStatus) {
        switch expiryStatus {
        case .expired:
            warning.isHidden = false
            warning.fillColor = WarningBubbleLabel.errorColor
        case .expiring:
            warning.isHidden = false
            warning.fillColor = WarningBubbleLabel.warningColor
        default:
            warning.isHidden = true
        }
    }
}

extension Decimal {
    var stringValue: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.locale = Locale.current
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        
        let number: NSNumber = NSDecimalNumber(decimal: self)
        
        return currencyFormatter.string(from: number) ?? ""
        
    }
}
