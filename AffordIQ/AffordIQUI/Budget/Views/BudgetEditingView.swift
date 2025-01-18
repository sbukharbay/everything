//
//  BudgetEditingView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 29.09.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class BudgetEditingView: UIView {
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [minusButton, currentSpendLabel, plusButton])
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()

    private let monthlyAverageLabel: FieldLabelSubheadlineLightBold = {
        let label = FieldLabelSubheadlineLightBold()
        label.text = "Monthly Average"
        label.textAlignment = .left
        return label
    }()

    private let monthlyAverageAmountLabel: InfoLabel = {
        let label = InfoLabel()
        label.textAlignment = .right
        return label
    }()

    private lazy var monthlyAvergeStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [monthlyAverageLabel, monthlyAverageAmountLabel])
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()

    private lazy var bottomButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, setButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.setCustomSpacing(12, after: cancelButton)
        return stack
    }()

    private lazy var minusButton: ClearButtonDarkTeal = {
        let button = ClearButtonDarkTeal()
        button.setTitle("-", for: .normal)
        button.addTarget(self, action: #selector(minusButtonTap), for: .touchUpInside)
        button.addTarget(self, action: #selector(minusButtonLongTap), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        return button
    }()

    private lazy var plusButton: ClearButtonDarkTeal = {
        let button = ClearButtonDarkTeal()
        button.setTitle("+", for: .normal)
        button.addTarget(self, action: #selector(plusButtonTap), for: .touchUpInside)
        button.addTarget(self, action: #selector(plusButtonLongTap), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        return button
    }()

    private lazy var currentSpendLabel: BudgetLargeLabel = {
        let label = BudgetLargeLabel()
        label.textAlignment = .center
        return label
    }()

    private lazy var setButton: PrimaryButtonLight = {
        let button = PrimaryButtonLight()
        button.setTitle("SET", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(onSetButtonTap), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: SecondaryButtonLight = {
        let button = SecondaryButtonLight()
        button.setTitle("CANCEL", for: .normal)
        button.addTarget(self, action: #selector(onCancelButtonTap), for: .touchUpInside)
        return button
    }()

    private let titleLabel: HeadingLabelBoldLight = {
        let label = HeadingLabelBoldLight()
        label.textAlignment = .center
        return label
    }()

    private var plusButtonAction: ((Int) -> Void)?
    private var minusButtonAction: ((Int) -> Void)?
    private var cancelButtonAction: (() -> Void)?
    private var setButtonAction: ((Int, MonetaryAmount) -> Void)?
    private var timer: Timer?
    private var distinction = 5
    private var seconds = 0.0
    private var currentSpend = 0
    private var spendingGoal: MonetaryAmount?
    private var averageSpend: MonetaryAmount?
    private var currentAdditionalSavings = 0

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(spendingGoal: MonetaryAmount?, averageSpend: MonetaryAmount?, categoryName: String, currentSpend: Int, plusButtonAction: ((Int) -> Void)?, minusButtonAction: ((Int) -> Void)?, cancelButtonAction: (() -> Void)?, setButtonAction: ((Int, MonetaryAmount) -> Void)?) {
        super.init(frame: .zero)

        self.currentSpend = currentSpend
        self.spendingGoal = spendingGoal
        self.averageSpend = averageSpend
        self.plusButtonAction = plusButtonAction
        self.minusButtonAction = minusButtonAction
        self.cancelButtonAction = cancelButtonAction
        self.setButtonAction = setButtonAction

        if spendingGoal == nil || averageSpend == spendingGoal {
            plusButton.isEnabled = false
        } else {
            plusButton.isEnabled = true
        }

        if spendingGoal != nil {
            currentSpendLabel.text = spendingGoal?.shortDescription
        } else {
            currentSpendLabel.text = averageSpend?.shortDescription
        }

        monthlyAverageAmountLabel.text = averageSpend?.shortDescription
        titleLabel.text = categoryName
        setButton.isEnabled = false

        setupViews()
    }

    private func setupViews() {
        backgroundColor = .white

        [titleLabel, buttonsStackView, monthlyAvergeStackView, bottomButtonsStackView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            buttonsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            monthlyAvergeStackView.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 32),
            monthlyAvergeStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            monthlyAvergeStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),

            plusButton.heightAnchor.constraint(equalToConstant: 50),
            plusButton.widthAnchor.constraint(equalToConstant: 50),

            minusButton.heightAnchor.constraint(equalToConstant: 50),
            minusButton.widthAnchor.constraint(equalToConstant: 50),

            bottomButtonsStackView.topAnchor.constraint(equalTo: monthlyAvergeStackView.bottomAnchor, constant: 32),
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),

            setButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func minusButtonTap() {
        if spendingGoal != nil, let spendingGoalAmount = spendingGoal?.amount {
            minusButtonImplementation(amount: spendingGoalAmount)
        } else {
            guard let initialAmount = averageSpend?.amount else { return }

            minusButtonImplementation(amount: initialAmount)
        }
    }

    func minusButtonImplementation(amount: Decimal) {
        seconds += 0.3

        if seconds >= 2 {
            distinction = 10
        }

        if !plusButton.isEnabled {
            plusButton.isEnabled = true
        }

        if currentSpend > 0 {
            setButton.isEnabled = true
            currentSpend -= distinction
        }

        if currentSpend <= 0 {
            minusButton.isEnabled = false
        }

        currentSpendLabel.text = "\(MonetaryAmount(amount: Decimal(roundCurrentSpend)).shortDescription)"
        currentAdditionalSavings = amount.rounded - roundCurrentSpend

        minusButtonAction?(currentAdditionalSavings)
    }

    var roundCurrentSpend: Int {
        if spendingGoal != nil, let spendingAmount = spendingGoal?.amount?.rounded, currentSpend == Int(spendingAmount) {
            return Int(spendingAmount)
        } else {
            if let initialAmount = averageSpend?.amount?.rounded, currentSpend == Int(initialAmount) {
                return Int(initialAmount)
            }
        }
        return (currentSpend + 4) / 5 * 5
    }

    @objc func plusButtonTap() {
        guard let unwrappedInitialAmount = averageSpend?.amount else { return }

        seconds += 0.3

        if seconds >= 2 {
            distinction = 10
        }

        if !minusButton.isEnabled {
            minusButton.isEnabled = true
        }

        if !setButton.isEnabled {
            setButton.isEnabled = true
        }

        if roundCurrentSpend < Int(unwrappedInitialAmount.rounded) {
            if roundCurrentSpend + distinction > Int(unwrappedInitialAmount.rounded) {
                currentAdditionalSavings -= Int(unwrappedInitialAmount.rounded) - roundCurrentSpend
                currentSpend = Int(unwrappedInitialAmount.rounded)
            } else {
                currentSpend += distinction
                currentAdditionalSavings -= distinction
            }
        }

        plusButton.isEnabled = !(currentSpend == Int(unwrappedInitialAmount.rounded))

        currentSpendLabel.text = "\(MonetaryAmount(amount: Decimal(roundCurrentSpend)).shortDescription)"

        plusButtonAction?(currentAdditionalSavings)
    }

    @objc func plusButtonLongTap() {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(plusButtonTap), userInfo: nil, repeats: true)
    }

    @objc func minusButtonLongTap() {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(minusButtonTap), userInfo: nil, repeats: true)
    }

    @objc func buttonReleased() {
        timer?.invalidate()
        timer = nil
        seconds = 0
        distinction = 5
    }

    @objc func onCancelButtonTap() {
        cancelButtonAction?()
    }

    @objc func onSetButtonTap() {
        let amount = MonetaryAmount(amount: Decimal(roundCurrentSpend))
        setButtonAction?(currentAdditionalSavings, amount)
    }
}
