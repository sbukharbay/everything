//
//  RenewConsentTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 31.07.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class RenewConsentTableViewCell: UITableViewCell, Stylable {
    private let icon: ProviderLogoImageView = {
        let icon = ProviderLogoImageView()
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private var titleLabel = FieldLabelSubheadlineLightBold()
    private var valueLabel = InfoLabelLight()
    
    private var renewLabel: FieldLabelSubheadlineLight = {
        let label = FieldLabelSubheadlineLight()
        label.text = "renew"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor(hex: "#72F0F0")
        switcher.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        switcher.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        switcher.isOn = true
        return switcher
    }()
    
    private lazy var accountsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private var whiteView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    static var reuseIdentifier = "RenewConsentTableViewCell"
    private var completion: ((Bool) -> Void)?
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func setup(accounts: [InstitutionAccount], completion: ((Bool) -> Void)?) {
        guard let bank = accounts.first else { return }
        
        self.completion = completion
        
        icon.imageURL = URL(string: bank.providerLogoUri)
        titleLabel.text = bank.providerDisplayName
        valueLabel.text = bank.consent != nil ? "Expires on " + bank.consent!.consentExpires.asStringDDMMYYYY() : ""
        
        accounts.forEach { account in
            accountsStackView.addArrangedSubview(getStackView(account: account))
        }
        
        setupLayout()
    }

    func setupLayout() {
        
        [whiteView, icon, titleLabel, valueLabel, switcher, renewLabel, accountsStackView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            whiteView.topAnchor.constraint(equalTo: contentView.topAnchor),
            whiteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            whiteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            whiteView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            icon.topAnchor.constraint(equalTo: whiteView.topAnchor, constant: 8),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            icon.heightAnchor.constraint(equalToConstant: 32),
            icon.widthAnchor.constraint(equalToConstant: 48),

            titleLabel.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            switcher.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            switcher.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            renewLabel.centerXAnchor.constraint(equalTo: switcher.centerXAnchor),
            renewLabel.topAnchor.constraint(equalTo: switcher.bottomAnchor, constant: 0),
            
            accountsStackView.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            accountsStackView.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            accountsStackView.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            accountsStackView.bottomAnchor.constraint(equalTo: whiteView.bottomAnchor, constant: -16)
        ])
    }
    
    func getStackView(account: InstitutionAccount) -> UIStackView {
        let title = InfoLabelLight()
        title.text = account.accountType?.descriptionSingular
        let subTitle = InfoLabelLight()
        subTitle.text = "\(account.accountNumber?.sortCode ?? String.missingValuePlaceholder) \(account.accountNumber?.number ?? String.missingValuePlaceholder)"
        
        let stackView = UIStackView(arrangedSubviews: [title, subTitle])
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        return stackView
    }
    
    @objc func switchValueDidChange() {
        renewLabel.text = switcher.isOn ? "renew" : "expire"
        completion?(switcher.isOn)
    }
}
