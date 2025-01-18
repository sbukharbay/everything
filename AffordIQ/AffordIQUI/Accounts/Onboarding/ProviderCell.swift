//
//  ProviderCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 05/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class ProviderCell: UITableViewCell {
    lazy var providerName = HeadingLabelBoldLight()

    lazy var providerLogo: ProviderLogoImageView = {
        let logo = ProviderLogoImageView()
        logo.contentMode = .scaleAspectFit
        return logo
    }()

    var viewModel: ProviderViewModel?

    static var reuseIdentifier = "Provider"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    func bind(provider: Provider, styles: AppStyles) {
        viewModel = ProviderViewModel(view: self, styles: styles, provider: provider)
    }

    private func setupLayout() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator

        [providerName, providerLogo].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            providerLogo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            providerLogo.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            providerLogo.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            providerLogo.widthAnchor.constraint(equalToConstant: 48),
            providerLogo.heightAnchor.constraint(equalToConstant: 48),

            providerName.leadingAnchor.constraint(equalTo: providerLogo.trailingAnchor, constant: 16),
            providerName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            providerName.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension ProviderCell: ProviderView {
    func set(providerName: NSAttributedString?) {
        self.providerName.attributedText = providerName
        accessibilityIdentifier = providerName?.string
    }

    func set(providerLogoURL: URL?) {
        providerLogo.imageURL = providerLogoURL
    }
}

protocol ProviderView: AnyObject {
    func set(providerName: NSAttributedString?)
    func set(providerLogoURL: URL?)
}

struct ProviderViewModel {
    weak var view: ProviderView?
    let styles: AppStyles
    let provider: Provider

    init(view: ProviderView, styles: AppStyles, provider: Provider) {
        self.view = view
        self.styles = styles
        self.provider = provider

        let titleAttributes: [NSAttributedString.Key: Any] = [.font: styles.fonts.sansSerif.headline]
        let providerName = NSAttributedString(string: provider.displayName, attributes: titleAttributes)
        view.set(providerName: providerName)

        let providerLogoURL = URL(string: provider.logoURL)
        view.set(providerLogoURL: providerLogoURL)
    }
}
