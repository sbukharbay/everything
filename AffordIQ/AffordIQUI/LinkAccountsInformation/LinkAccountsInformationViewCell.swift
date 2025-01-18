//
//  LinkAccountsInformationViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 25/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class LinkAccountsInformationViewCell: UICollectionViewCell, Stylable {
    var page: Page? {
        didSet {
            guard let unwrappedCell = page else { return }

            accountImageView.image = UIImage(named: unwrappedCell.imageName, in: uiBundle, compatibleWith: nil)
            headerLabel.text = unwrappedCell.headerText
            descriptionLabel.text = unwrappedCell.bodyText
        }
    }

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let accountImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var headerLabel = HeadingTitleLabel()

    private let descriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.5
        return label
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [accountImageView, headerLabel])
        stackView.distribution = .fillProportionally
        stackView.setCustomSpacing(16, after: accountImageView)
        stackView.axis = .horizontal
        return stackView
    }()

    static var reuseIdentifier = "LinkAccountsInformation"

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        [blurEffectView, horizontalStackView, descriptionLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 56),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),

            horizontalStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            horizontalStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(equalTo: widthAnchor)
        ])
    }
}
