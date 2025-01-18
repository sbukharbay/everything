//
//  AffordabilityInformationCarouselViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 13/12/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class AffordabilityInformationCarouselViewCell: UICollectionViewCell, Stylable {
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Set a Goal"
        label.textAlignment = .center
        return label
    }()

    private let subTitleLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "A Goal is made up of these steps:"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let titleIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "goal", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleIconImage, headerLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.setCustomSpacing(8, after: titleIconImage)
        return stackView
    }()

    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()

    static var reuseIdentifier = "AffordabilityCarouselCell"

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        [blurEffectView, horizontalStackView, subTitleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 56),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),

            horizontalStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            horizontalStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            subTitleLabel.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: 8),
            subTitleLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
            subTitleLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16)
        ])
    }

    func setupLayout(model: [Page]) {
        verticalStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        model.forEach { item in
            verticalStackView.addArrangedSubview(getStackView(model: item, isVertical: model.count == 2))
        }

        subTitleLabel.isHidden = model.count == 2

        addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 8),
            verticalStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16)
        ])
    }

    func getStackView(model: Page, isVertical: Bool) -> UIStackView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        let subHeaderLabel = HeadlineLabelDark()
        subHeaderLabel.numberOfLines = 0

        let bodyLabel = FieldLabelDark()
        bodyLabel.numberOfLines = 0

        imageView.image = UIImage(named: model.imageName, in: uiBundle, compatibleWith: nil)
        subHeaderLabel.text = model.headerText
        bodyLabel.text = model.bodyText

        let stackView = UIStackView()
        stackView.distribution = .fill

        if isVertical {
            [imageView, subHeaderLabel, bodyLabel].forEach {
                stackView.addArrangedSubview($0)
            }
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 8

            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 32)
            ])
        } else {
            let rightStackView = UIStackView(arrangedSubviews: [subHeaderLabel, bodyLabel])
            rightStackView.axis = .vertical
            rightStackView.distribution = .fillProportionally
            rightStackView.setCustomSpacing(8, after: subHeaderLabel)

            subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
            bodyLabel.translatesAutoresizingMaskIntoConstraints = false

            [imageView, rightStackView].forEach {
                stackView.addArrangedSubview($0)
                stackView.translatesAutoresizingMaskIntoConstraints = false
            }
            stackView.axis = .horizontal
            stackView.alignment = .top
            stackView.spacing = 16

            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 30),
                imageView.widthAnchor.constraint(equalToConstant: 30)
            ])
        }

        return stackView
    }
}
