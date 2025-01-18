//
//  BudgetDetailsViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 28.09.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class BudgetDetailsViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)
    
    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()

    private let topBlurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let categoryImageView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.tintColor = UIColor(hex: "#72F0F0")
        return icon
    }()

    private let categoryLabel: HeadingLabelInfo = .init()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [categoryImageView, categoryLabel])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.setCustomSpacing(12, after: categoryImageView)
        stackView.alignment = .center
        return stackView
    }()

    private let budgetCircleMeterView: CircularMeterView = {
        let meter = CircularMeterView(frame: .zero)
        meter.numberOfSegments = 16
        meter.lineWidth = 6
        meter.isClockwise = true
        return meter
    }()

    private let budgetValueLabel: DashboardLargeLabel = .init()

    private let goalTitleLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Budget Goal"
        label.textAlignment = .left
        return label
    }()

    private let goalValueLabel: BodyLabelDark = .init()

    private lazy var goalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [goalTitleLabel, goalValueLabel])
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private let averageTitleLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Monthly Average"
        label.textAlignment = .left
        return label
    }()

    private let averageValueLabel: BodyLabelDark = .init()

    private lazy var averageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [averageTitleLabel, averageValueLabel])
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        return stackView
    }()

    private lazy var editButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()

    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var budgetEditingView: BudgetEditingView?
    private var viewModel: BudgetDetailsViewModel?
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        contentSizeMonitor.removeObserver()
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    func bind(styles: AppStyles = AppStyles.shared, spending: SpendingBreakdownCategory) {
        setupViews()
        apply(styles: styles)

        viewModel = BudgetDetailsViewModel(spending: spending)
        
        setupListeners()
        
        categoryLabel.text = spending.name
        budgetValueLabel.text = spending.actualSpend.shortDescription
        goalValueLabel.text = spending.spendingGoal?.shortDescription ?? "-/-"
        averageValueLabel.text = spending.monthlyAverage.shortDescription

        if let image = UIImage(named: spending.icon, in: uiBundle, compatibleWith: nil) {
            categoryImageView.image = image.withTintColor(UIColor(hex: "#72F0F0"), renderingMode: .alwaysTemplate)
        } else if let image = UIImage(systemName: spending.icon) {
            categoryImageView.image = image
        }

        if let percent = spending.spendGoalPercentage?.floatValue {
            budgetCircleMeterView.progress = percent / 100
        } else {
            budgetCircleMeterView.progress = 0
        }

        bringFeedbackButton(String(describing: type(of: self)))
    }

    func setupViews() {
        [backgroundImageView, topBlurEffectView, titleStackView, budgetCircleMeterView, budgetValueLabel, goalStackView, averageStackView, editButton, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            topBlurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            topBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBlurEffectView.bottomAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 24),

            titleStackView.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor, constant: 16),
            titleStackView.centerXAnchor.constraint(equalTo: topBlurEffectView.centerXAnchor),

            categoryImageView.heightAnchor.constraint(equalToConstant: 24),
            categoryImageView.widthAnchor.constraint(equalToConstant: 24),

            budgetCircleMeterView.heightAnchor.constraint(equalToConstant: 140),
            budgetCircleMeterView.widthAnchor.constraint(equalToConstant: 140),
            budgetCircleMeterView.centerXAnchor.constraint(equalTo: topBlurEffectView.centerXAnchor),
            budgetCircleMeterView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 24),

            budgetValueLabel.centerXAnchor.constraint(equalTo: budgetCircleMeterView.centerXAnchor),
            budgetValueLabel.centerYAnchor.constraint(equalTo: budgetCircleMeterView.centerYAnchor),

            goalStackView.topAnchor.constraint(equalTo: budgetCircleMeterView.bottomAnchor, constant: 16),
            goalStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 24),
            goalStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -24),

            averageStackView.topAnchor.constraint(equalTo: goalStackView.bottomAnchor, constant: 16),
            averageStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 24),
            averageStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -24),

            editButton.topAnchor.constraint(equalTo: averageStackView.bottomAnchor, constant: 32),
            editButton.heightAnchor.constraint(equalToConstant: 40),
            editButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.$operationComplete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.operationComplete()
            }
            .store(in: &subscriptions)
    }

    @objc private func handleEdit() {
        guard let vm = viewModel else { return }
        var current = 0

        if let amount = vm.spending.spendingGoal?.amount?.doubleValue {
            current = Int(amount)
        } else if let amount = vm.spending.monthlyAverage.amount?.doubleValue {
            current = Int(amount)
        }

        budgetEditingView = BudgetEditingView(spendingGoal: vm.spending.spendingGoal, averageSpend: vm.spending.monthlyAverage, categoryName: vm.spending.name, currentSpend: current, plusButtonAction: { savings in
            if let goal = vm.spending.spendingGoal?.amount?.rounded {
                self.goalValueLabel.text = "£\(goal - savings)"
            } else {
                self.goalValueLabel.text = "£\(savings)"
            }
        }, minusButtonAction: { savings in
            if let goal = vm.spending.spendingGoal?.amount?.rounded {
                self.goalValueLabel.text = "£\(goal - savings)"
            } else {
                self.goalValueLabel.text = "£\(savings)"
            }
        }, cancelButtonAction: {
            self.operationComplete()
            self.goalValueLabel.text = vm.spending.spendingGoal?.shortDescription ?? "-/-"
        }, setButtonAction: { saving, amount in
            if vm.spending.spendingGoal != nil {
                vm.spending.spendingGoal = amount
                Task {
                    await vm.setMonthlySavingsGoal(amount)
                }
            } else {
                let monetary = MonetaryAmount(amount: Decimal(saving))
                vm.spending.spendingGoal = monetary
                Task {
                    await vm.setMonthlySavingsGoal(monetary)
                }
            }
            self.goalValueLabel.text = vm.spending.spendingGoal?.shortDescription ?? "-/-"
            self.budgetCircleMeterView.progress = ((vm.spending.actualSpend.amount?.floatValue ?? 0) / (vm.spending.spendingGoal?.amount?.floatValue ?? 0))
        })

        view.addSubview(budgetEditingView!)
        budgetEditingView?.translatesAutoresizingMaskIntoConstraints = false
        budgetEditingView?.layer.cornerRadius = 30
        budgetEditingView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        NSLayoutConstraint.activate([
            budgetEditingView!.topAnchor.constraint(equalTo: editButton.topAnchor),
            budgetEditingView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            budgetEditingView!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            budgetEditingView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        apply(styles: vm.styles)
    }

    func operationComplete() {
        budgetEditingView?.removeFromSuperview()
    }
}

extension BudgetDetailsViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles = viewModel?.styles {
            apply(styles: styles)
        }
    }
}
