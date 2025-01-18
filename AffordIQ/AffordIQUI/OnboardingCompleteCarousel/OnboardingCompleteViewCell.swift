//
//  OnboardingCompleteViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 16/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class OnboardingCompleteViewCell: UICollectionViewCell, Stylable {
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let bkView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.backgroundColor = .systemBlue
        view.backgroundColor = UIColor(hex: "070728")
        return view
    }()

    let bodyLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    static var reuseIdentifier = "OnboardingCompleteCell"

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        [blurEffectView, bkView, bodyLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            bkView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.frame.height / 1.5),
            bkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bkView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -48),

            bodyLabel.topAnchor.constraint(equalTo: bkView.topAnchor, constant: 16),
            bodyLabel.leadingAnchor.constraint(equalTo: bkView.leadingAnchor, constant: 24),
            bodyLabel.trailingAnchor.constraint(equalTo: bkView.trailingAnchor, constant: -24),
            bodyLabel.bottomAnchor.constraint(equalTo: bkView.bottomAnchor, constant: -24)
        ])
    }

    func setupData(text: String) {
        bodyLabel.text = text
    }
}
