//
//  SavingBudgetViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 28/06/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class SavingBudgetViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private(set) lazy var backgroundImageView: BackgroundImageView = .init(frame: view.frame)

    private(set) lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let view = CustomNavigationBar(title: "Set a Goal", rightButtonTitle: "Set") { [weak self] in
            self?.leftButtonAction()
        } rightButtonAction: {
            Task {
                await self?.viewModel?.setMonthlySavingsGoal()
            }
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "repayments", in: uiBundle, compatibleWith: nil)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var headerLabel: HeadingTitleLabel = {
        let view = HeadingTitleLabel()
        view.text = "Budget"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var titleStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .horizontal
        view.setCustomSpacing(12, after: iconImageView)
        view.alignment = .bottom
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var circleMeterView: CircularMeterView = {
        let view = CircularMeterView(frame: .zero)
        view.numberOfSegments = 16
        view.lineWidth = 6
        view.isClockwise = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var monthsLabel: DashboardLargeLabel = {
        let view = DashboardLargeLabel()
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var untilAffordableLabel: FieldLabelDark = {
        let view = FieldLabelDark()
        view.text = "Months until affordable"
        view.numberOfLines = 0
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var meterLabelStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var additionalSavingsLabel: HeadlineLabelDark = {
        let view = HeadlineLabelDark()
        view.text = "Additional Savings"
        view.numberOfLines = 0
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var additionalSavingsAmountLabel: HeadingTitleLabelLight = {
        let view = HeadingTitleLabelLight()
        view.text = "£0"
        view.numberOfLines = 0
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var additionalSavingsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.setCustomSpacing(8, after: additionalSavingsLabel)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var buyingHomeLabel: FieldLabelDark = {
        let view = FieldLabelDark()
        view.text = "Total Savings"
        view.textAlignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var savingsAmountLabel: FieldLabelBoldDark = {
        let view = FieldLabelBoldDark()
        view.textAlignment = .right
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var depositSavingsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [buyingHomeLabel, savingsAmountLabel])
        view.axis = .horizontal
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var overlayView: TableOverlayView = {
        let view = TableOverlayView(frame: .zero)
        view.tabVisible = false
        view.heading = nil
        view.title = nil
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.backgroundColor = .clear
        view.separatorColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(SavingBudgetTableViewCell.self)
        view.register(SavingBudgetTablewViewHeader.self)
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var whiteBackround: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var emptyTableDescription: InfoLabel = {
        let view = InfoLabel()
        view.text = "Link a bank account with valid transactions to set and manage your budget goals."
        view.textAlignment = .center
        view.isHidden = true
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private var budgetEditingView: BudgetEditingView?
    private var viewModel: SavingBudgetViewModel?
    private var isClicked = false
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var styles: AppStyles?
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setCustomNavBarConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }

    func bind(isDashboard: Bool, styles: AppStyles = AppStyles.shared ) {
        loadViewIfNeeded()

        viewModel = SavingBudgetViewModel(isDashboard: isDashboard)
        setupSubviews()
        setupListeners()
        
        apply(styles: styles)
        self.styles = styles

        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.updateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.update()
            }
            .store(in: &subscriptions)
        
        viewModel?.updateTableSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateTable()
            }
            .store(in: &subscriptions)
        
        viewModel?.onboardingCompleteSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.operationComplete()
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    showLoadingView()
                } else {
                    hideLoadingView()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func showLoadingView() {
        guard let navigationController else { return }
        BusyView.shared.show(
            navigationController: navigationController,
            title: NSLocalizedString("Loading...", bundle: uiBundle, comment: "Loading..."),
            fullScreen: false
        )
    }
    
    private func hideLoadingView() {
        BusyView.shared.hide(success: true)
    }

    func leftButtonAction() {
        if isClicked {
            tableViewLayout()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - TableView
extension SavingBudgetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel?.topCategories.count ?? 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel, let styles else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(SavingBudgetTableViewCell.self, for: indexPath)
        cell.style(styles: styles)
        
        cell.titleLabel.text = vm.topCategories[indexPath.row].categoryName
        
        if vm.topCategories[indexPath.row].spendingGoal != nil {
            cell.monthlyAverageLabel.text = "Budget Goal"
            cell.monthlyAmountLabel.text = vm.topCategories[indexPath.row].spendingGoal?.shortDescription
        } else {
            cell.monthlyAverageLabel.text = "Monthly Average"
            cell.monthlyAmountLabel.text = vm.topCategories[indexPath.row].averageSpend.shortDescription
        }
        
        cell.circleMeterView.progress = Float(vm.topCategories[indexPath.row].savedAmount) / Float(truncating: vm.topCategories[indexPath.row].averageSpend.amount! as NSNumber)
        
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.currentIndex = indexPath.row
        changeSpendTargetLayout()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooter(SavingBudgetTablewViewHeader.self)
        view.setup()
        view.apply(styles: AppStyles.shared)
        
        return view
    }
    
    func operationComplete() {
        guard let viewModel else { return }
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                if viewModel.isDashboard {
                    presenter.popViewController(animated: true)
                } else {
                    viewModel.onboardingCompleteStep()
                    
                    let coordinator = SetAGoalCheckPointCoordinator(presenter: presenter, type: .budget)
                    coordinator.start()
                }
            })
        }
    }
}

// MARK: - Update
extension SavingBudgetViewController {
    func update() {
        guard let vm = viewModel else { return }

        monthsLabel.text = vm.months > 36 ? "36+" : vm.months.description

        switch vm.months {
        case 0:
            monthsLabel.text = "NOW"
            untilAffordableLabel.text = "Affordable"
        case 1:
            untilAffordableLabel.text = "Month until affordable"
        default:
            untilAffordableLabel.text = "Months until affordable"
        }
        
        circleMeterView.progress = vm.months >= 48 ? 0 : (48 - Float(vm.months)) / 48

        if let unwrappedAmount = vm.savingsPerMonth?.shortDescription {
            savingsAmountLabel.text = "\(unwrappedAmount)/m"
        }
    }

    func updateTable() {
        guard let viewModel else { return }

        emptyTableDescription.isHidden = !viewModel.topCategories.isEmpty
        
        additionalSavingsAmountLabel.text = "£\(viewModel.overallAdditionalSavings <= 0 ? 0 : viewModel.overallAdditionalSavings)"
        tableView.reloadData()
    }
}

// MARK: - Layout

extension SavingBudgetViewController {
    func changeSpendTargetLayout() {
        guard let vm = viewModel, let styles else { return }
        
        let category = vm.topCategories[vm.currentIndex]
        vm.spendingGoalCheck()
        isClicked = true
        
        budgetEditingView = BudgetEditingView(spendingGoal: category.spendingGoal, averageSpend: category.averageSpend, categoryName: category.categoryName, currentSpend: vm.currentSpend, plusButtonAction: { savings in
            vm.currentAdditionalSavings = savings
            self.additionalSavingsAmountLabel.text = "£\(vm.overallAdditionalSavings + savings <= 0 ? 0 : vm.overallAdditionalSavings + savings)"
        }, minusButtonAction: { savings in
            vm.currentAdditionalSavings = savings
            self.additionalSavingsAmountLabel.text = "£\(savings + vm.overallAdditionalSavings)"
        }, cancelButtonAction: {
            self.tableViewLayout()
            self.additionalSavingsAmountLabel.text = "£\(vm.overallAdditionalSavings)"
        }, setButtonAction: { currentAdditionalSavings, amount in
            vm.topCategories[vm.currentIndex].spendingGoal = amount
            vm.overallAdditionalSavings += vm.currentAdditionalSavings
            vm.topCategories[vm.currentIndex].savedAmount += currentAdditionalSavings
            
            self.updateTable()
            
            vm.confirmNewSpendingTarget()
            
            self.tableViewLayout()
        })
        
        view.addSubview(budgetEditingView!)
        budgetEditingView?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            budgetEditingView!.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 24),
            budgetEditingView!.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 24),
            budgetEditingView!.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -24),
            budgetEditingView!.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor)
        ])
        
        apply(styles: styles)
    }

    func tableViewLayout() {
        isClicked = false
        budgetEditingView?.removeFromSuperview()
    }
}

extension SavingBudgetViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
