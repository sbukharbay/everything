//
//  SavingBudgetTableViewCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 30/06/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class SavingBudgetTableViewCell: NiblessTableViewCell, ReusableElement, Stylable {
    let circleMeterView: CircularMeterView = {
        let meter = CircularMeterView(frame: .zero)
        meter.numberOfSegments = 16
        meter.lineWidth = 6
        meter.isClockwise = true
        meter.progress = 0
        meter.trackColor = UIColor(hex: "#99A0AA")
        meter.color4 = UIColor(hex: "#2BA3B3")
        return meter
    }()

    let titleLabel: HeadingLabelLight = {
        let label = HeadingLabelLight()
        label.textAlignment = .left
        return label
    }()

    let monthlyAverageLabel: InfoLabel = {
        let label = InfoLabel()
        label.text = "Monthly Average"
        label.textAlignment = .left
        return label
    }()

    private lazy var labelStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, monthlyAverageLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        return stack
    }()

    let monthlyAmountLabel: InfoLabel = {
        let label = InfoLabel()
        label.textAlignment = .right
        return label
    }()

    private lazy var cellStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [circleMeterView, labelStackView, monthlyAmountLabel])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.setCustomSpacing(8, after: circleMeterView)
        return stack
    }()

    static var reuseIdentifier = "BudgetGoalTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none

        [cellStackView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            cellStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            circleMeterView.heightAnchor.constraint(equalToConstant: 50),
            circleMeterView.widthAnchor.constraint(equalToConstant: 50),

            monthlyAmountLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.25)
        ])
    }
}
