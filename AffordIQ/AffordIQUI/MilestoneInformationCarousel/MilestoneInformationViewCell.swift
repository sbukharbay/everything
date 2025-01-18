//
//  MilestoneInformationViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 09/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class MilestoneInformationViewCell: UICollectionViewCell, Stylable {
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    let headerLabel: TitleLabelMarkerBlue = {
        let label = TitleLabelMarkerBlue()
        label.numberOfLines = 0
        return label
    }()

    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let descriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        return label
    }()

    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    static var reuseIdentifier = "SetCompassCell"

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        [blurEffectView, headerLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 56),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),

            headerLabel.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 32),
            headerLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
            headerLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -32)
        ])
    }

    func setupSingleLayout(model: Page) {
        [iconImage, descriptionLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            iconImage.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 40),
            iconImage.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -40),
            iconImage.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16),
            iconImage.heightAnchor.constraint(equalToConstant: frame.height / 2.4),
            iconImage.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),

            descriptionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -32)
        ])

        iconImage.image = UIImage(named: model.imageName, in: uiBundle, compatibleWith: nil)
        descriptionLabel.text = model.bodyText
    }

    func setupManyLayout(model: [Page]) {
        model.forEach { item in
            verticalStackView.addArrangedSubview(getStackView(model: item))
        }

        [verticalStackView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 32),
            verticalStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 24),
            verticalStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24)
        ])
    }

    func getStackView(model: Page) -> UIStackView {
        let imageView = UIImageView()
        imageView.contentMode = .top

        let bodyLabel = FieldLabelDark()
        bodyLabel.numberOfLines = 0

        let subHeadingLabel = HeadlineLabelDark()

        imageView.image = UIImage(named: model.imageName, in: uiBundle, compatibleWith: nil)
        subHeadingLabel.text = model.headerText
        bodyLabel.text = model.bodyText

        let stackView = UIStackView(arrangedSubviews: [subHeadingLabel, bodyLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.setCustomSpacing(4, after: subHeadingLabel)

        let wrappedStackView = UIStackView(arrangedSubviews: [imageView, stackView])
        wrappedStackView.axis = .horizontal
        wrappedStackView.distribution = .fill
        wrappedStackView.setCustomSpacing(24, after: imageView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24)
        ])

        return wrappedStackView
    }
}
