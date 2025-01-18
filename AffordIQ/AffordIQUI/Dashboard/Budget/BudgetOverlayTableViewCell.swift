//
//  BudgetOverlayTableViewCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.08.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class BudgetOverlayTableViewCell: UITableViewCell, Stylable {
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#45AEBC")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var titleLabel: BodyLabelLightSemiBold = {
        let label = BodyLabelLightSemiBold()
        label.numberOfLines = 0
        return label
    }()

    private var valueLabel: BodyLabelLight = {
        let label = BodyLabelLight()
        label.textAlignment = .right
        return label
    }()

    private var budgetLabel: InfoLabel = .init()

    private lazy var middleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, budgetLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        return stackView
    }()

    private lazy var parentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [icon, middleStackView, valueLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(18, after: icon)
        stackView.alignment = .center
        return stackView
    }()

    private let budgetCircleMeterView: CircularMeterView = {
        let meter = CircularMeterView(frame: .zero)
        meter.numberOfSegments = 16
        meter.lineWidth = 6
        meter.isClockwise = true
        meter.translatesAutoresizingMaskIntoConstraints = false
        return meter
    }()

    static var reuseIdentifier = "BudgetOverlayTableViewCell"

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
        backgroundColor = .clear
        selectionStyle = .none
    }

    private func setupLayout() {
        contentView.addSubview(parentStackView)

        NSLayoutConstraint.activate([
            parentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            parentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            parentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            parentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            icon.heightAnchor.constraint(equalToConstant: 24),
            icon.widthAnchor.constraint(equalToConstant: 24)
        ])
    }

    func setData(data: SpendingBreakdownCategory, isDiscretionary: Bool) {
        if let image = UIImage(named: data.icon, in: uiBundle, compatibleWith: nil) {
            icon.image = image.withTintColor(UIColor(hex: "#45AEBC"), renderingMode: .alwaysTemplate)
        } else if let image = UIImage(systemName: data.icon) {
            icon.image = image
        }

        titleLabel.text = data.name
        valueLabel.text = data.actualSpend.longDescription

        if isDiscretionary {
            setupCircleMeter(data)
        } else {
            budgetCircleMeterView.isHidden = true
            middleStackView.spacing = 0
            budgetLabel.text = nil
            icon.tintColor = UIColor(hex: "#45AEBC")
        }
    }

    private func setupCircleMeter(_ data: SpendingBreakdownCategory) {
        contentView.addSubview(budgetCircleMeterView)

        NSLayoutConstraint.activate([
            budgetCircleMeterView.centerXAnchor.constraint(equalTo: icon.centerXAnchor),
            budgetCircleMeterView.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            budgetCircleMeterView.heightAnchor.constraint(equalToConstant: 48),
            budgetCircleMeterView.widthAnchor.constraint(equalToConstant: 48)
        ])

        middleStackView.spacing = 4
        budgetCircleMeterView.isHidden = false

        if data.spendingGoal?.amount == 0, let actualSpend = data.actualSpend.amount, actualSpend > 0 {
            setZeroBudget()
        } else if data.monthlyAverage.amount == 0, let actualSpend = data.actualSpend.amount, actualSpend > 0 {
            setZeroBudget()
        } else if let percentage = data.spendGoalPercentage?.floatValue {
            budgetCircleMeterView.progress = percentage / 100
            budgetLabel.text = Int(percentage).description + "% of Budget"

            colorSpending(percentage >= 100)
        } else {
            setZeroBudget()
        }
    }

    func setZeroBudget() {
        budgetCircleMeterView.progress = 1
        budgetLabel.text = MonetaryAmount(amount: 0).longDescription + " Budget"

        colorSpending(true)
    }

    func colorSpending(_ isOverSpent: Bool) {
        if isOverSpent {
            budgetCircleMeterView.color1 = UIColor(hex: "#E6114E")
            budgetCircleMeterView.color2 = UIColor(hex: "#E6114E")
            budgetCircleMeterView.color3 = UIColor(hex: "#E6114E")
            budgetCircleMeterView.color4 = UIColor(hex: "#E6114E")
            icon.tintColor = UIColor(hex: "#E6114E")
        } else {
            budgetCircleMeterView.color1 = UIColor(hex: "#30f2fc")
            budgetCircleMeterView.color2 = UIColor(hex: "#2ec7ce")
            budgetCircleMeterView.color3 = UIColor(hex: "#028e8e")
            budgetCircleMeterView.color4 = UIColor(hex: "#014766")
            icon.tintColor = UIColor(hex: "#45AEBC")
        }
    }
}
