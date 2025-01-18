//
//  BudgetViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 10.08.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class BudgetViewController: FloatingButtonController, Stylable, DashboardBindable, ErrorPresenter {
    private(set) lazy var topBlurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private(set) lazy var leisureCircleMeterView: CircularMeterView = {
        let meter = CircularMeterView(frame: .zero)
        meter.numberOfSegments = 16
        meter.lineWidth = 6
        meter.isClockwise = false
        return meter
    }()

    private(set) lazy var leisureTopLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .center
        label.text = "Approx."
        return label
    }()

    private(set) lazy var leisureMidLabel: DashboardLargeLabel = {
        let label = DashboardLargeLabel()
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var leisureBottomLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .center
        label.text = "Left to spend this month"
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var leisureStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leisureTopLabel, leisureMidLabel, leisureBottomLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.layer.cornerRadius = 5
        progressBar.layer.masksToBounds = true
        progressBar.trackTintColor = UIColor(white: 1, alpha: 0.3)
        progressBar.progressImage = UIImage(named: "progress_bar", in: uiBundle, compatibleWith: nil)
        progressBar.setProgress(0.5, animated: false)
        return progressBar
    }()

    private(set) lazy var infoLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var titleLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Living Costs"
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var titleCurrentLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "This Month"
        return label
    }()

    private(set) lazy var titleProjectedLabel: FieldLabelDarkRight = {
        let label = FieldLabelDarkRight()
        label.text = "Projected"
        return label
    }()

    private(set) lazy var costTitlesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleCurrentLabel, titleProjectedLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private(set) lazy var notificationButton: BadgeButton = {
        let button = BadgeButton(frame: .init(origin: .zero, size: CGSize(width: 20, height: 20)))
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.imageView?.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    private(set) lazy var amountCurrentLabel: BodyLabelDarkSemiBold = .init()

    private(set) lazy var amountProjectedLabel: BodyLabelDarkSemiBold = .init()

    private(set) lazy var costAmountsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [amountCurrentLabel, amountProjectedLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private(set) lazy var livingCostStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, progressBar, costTitlesStackView, costAmountsStackView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()

    private(set) lazy var overlayView: TableOverlayView = {
        let view = TableOverlayView(frame: .zero)
        view.tabVisible = true
        view.heading = nil
        view.title = nil
        view.delegate = self
        return view
    }()

    private(set) lazy var staticTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.sectionHeaderHeight = 0
        tableView.register(BudgetStaticTableViewCell.self)
        
        return tableView
    }()

    private(set) lazy var helpButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hex: "72F0F0")
        button.setBackgroundImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(onHelpButtonTap), for: .touchUpInside)
        return button
    }()

    private(set) lazy var alertView: CustomTopAlertView = .init(title: "Help", icon: UIImage(systemName: "questionmark.circle"), message: alertMessage, buttonTitle: "Ok", buttonAction: {
        self.alertView.removeFromSuperview()
    })
    
    private(set) lazy var emptyLabel: InfoLabel = {
        let view = InfoLabel()
        view.text = "Link a bank account with valid transactions to set and manage your budget goals."
        view.textAlignment = .center
        view.numberOfLines = 0
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private var viewModel: BudgetViewModel?
    private var styles: AppStyles?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var openConstraint: NSLayoutConstraint?
    private var alertMessage: NSMutableAttributedString = .init()
    private var subscriptions = Set<AnyCancellable>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        contentSizeMonitor.removeObserver()
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        let height = view.frame.height / 5.5

        NSLayoutConstraint.activate([
            leisureCircleMeterView.heightAnchor.constraint(equalToConstant: height),
            leisureCircleMeterView.widthAnchor.constraint(equalToConstant: height),

            staticTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func bind(styles: AppStyles = AppStyles.shared) {
        viewModel = BudgetViewModel()

        let max: Float = 273.0 * 0.75 + 273.0
        leisureCircleMeterView.progress = (max - 273.0) / max

        navBarSetup()

        if let tableView = overlayView.tableView {
            createDataSource(tableView: tableView)
        }

        self.styles = styles
        setupViews()
        setupListeners()
        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
        setupSwipeGesture()
    }

    func setupViews() {
        [topBlurEffectView, leisureCircleMeterView, leisureStackView, helpButton, livingCostStackView, infoLabel, overlayView, staticTableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        overlayView.addSubview(emptyLabel)

        openConstraint = overlayView.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor)
        openConstraint?.priority = UILayoutPriority(1.0)
        openConstraint?.isActive = true

        NSLayoutConstraint.activate([
            topBlurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBlurEffectView.bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 32),

            leisureCircleMeterView.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor, constant: 24),
            leisureCircleMeterView.centerXAnchor.constraint(equalTo: topBlurEffectView.centerXAnchor),

            helpButton.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),
            helpButton.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor, constant: 16),
            helpButton.heightAnchor.constraint(equalToConstant: 24),
            helpButton.widthAnchor.constraint(equalToConstant: 24),

            leisureStackView.centerXAnchor.constraint(equalTo: leisureCircleMeterView.centerXAnchor),
            leisureStackView.centerYAnchor.constraint(equalTo: leisureCircleMeterView.centerYAnchor),
            leisureStackView.leadingAnchor.constraint(equalTo: leisureCircleMeterView.leadingAnchor, constant: 8),
            leisureStackView.trailingAnchor.constraint(equalTo: leisureCircleMeterView.trailingAnchor, constant: -8),

            livingCostStackView.topAnchor.constraint(equalTo: leisureCircleMeterView.bottomAnchor, constant: 24),
            livingCostStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 24),
            livingCostStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -24),
            livingCostStackView.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -32),

            progressBar.heightAnchor.constraint(equalToConstant: 10),

            infoLabel.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 48),
            infoLabel.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -48),

            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            overlayView.bottomAnchor.constraint(equalTo: staticTableView.topAnchor, constant: 28),

            staticTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            staticTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            staticTableView.heightAnchor.constraint(equalToConstant: 96),
            
            emptyLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -24)
        ])
    }

    private func navBarSetup() {
        let leftItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: self, action: #selector(leftButtonHandle))
        leftItem.tintColor = .white
    
        notificationButton.addTarget(self, action: #selector(rightButtonHandle), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: notificationButton)

        navigationItem.setLeftBarButton(leftItem, animated: false)
        navigationItem.setRightBarButton(rightItem, animated: false)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
    }

    func createDataSource(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BudgetOverlayTableViewCell.self)
        tableView.register(BudgetOverlayHeaderView.self, forHeaderFooterViewReuseIdentifier: BudgetOverlayHeaderView.reuseIdentifier)
    }

    func resume() {
        viewModel?.resume()
    }

    @objc func leftButtonHandle() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = DashboardSettingsCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }

    @objc func rightButtonHandle() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = NotificationsCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }
    
    func navigateToBudgetDetails(_ index: Int) {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = BudgetDetailsCoordinator(presenter: presenter, spending: viewModel.discretionary[index])
                coordinator.start()
            })
        }
    }
    
    private func setupListeners() {
        NotificationManager.shared.$notificationCounter
            .sink { [weak self] newValue in
                guard let self else { return }
                self.notificationButton.addBadgeToButton(
                    badge: newValue == 0 ? nil : String(newValue)
                )
            }
            .store(in: &subscriptions)
        
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.$hideOverlayTable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.overlayView.close()
            }
            .store(in: &subscriptions)
        
        viewModel?.$update
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &subscriptions)
        
        viewModel?.$updateBottom
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.staticTableView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel?.$updateSpendingTable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.overlayView.tableView?.reloadData()
            }
            .store(in: &subscriptions)
    }

    func update() {
        guard let vm = viewModel, let styles else { return }

        leisureMidLabel.text = vm.monthlySpending?.discretionary.leftToSpend.amount ?? 0 <= 0 ? "£0" : vm.monthlySpending?.discretionary.leftToSpend.shortDescription
        amountCurrentLabel.text = vm.monthlySpending?.nonDiscretionary.currentSpend.shortDescription
        amountProjectedLabel.text = vm.monthlySpending?.nonDiscretionary.averageSpend.shortDescription

        let progress = (vm.monthlySpending?.nonDiscretionary.currentSpend.amount ?? 1) / (vm.monthlySpending?.nonDiscretionary.averageSpend.amount ?? 1)
        progressBar.setProgress(progress.floatValue, animated: false)

        switch vm.monthlySpending?.discretionary.pattern {
        case .break:
            infoLabel.text = "✋ You are on track to break your budget this month."
            alertMessage = NSMutableAttributedString()
                .style("We estimate that you have ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(vm.leftToSpend.shortDescription, font: styles.fonts.sansSerif.subheadline.bold)
                .style(" left to spend this month on groceries and non-essential expenses, while still reaching your savings goal of ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(vm.savingsGoal, font: styles.fonts.sansSerif.subheadline.bold)
                .style(".\n\n", font: styles.fonts.sansSerif.subheadline.regular)
                .style("Note:\n", font: styles.fonts.sansSerif.subheadline.bold)
                .style("This is just an estimate based on your average living costs and monthly income. ", font: styles.fonts.sansSerif.subheadline.regular)
                .style("If your living costs this month are higher than average, or your income is lower than expected you may not reach your savings goal even if you spend within budget.", font: styles.fonts.sansSerif.subheadline.regular)
        case .meet:
            infoLabel.text = "👍 You are on track to meet your budget this month."
            alertMessage = NSMutableAttributedString()
                .style("We estimate that you have ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(vm.leftToSpend.shortDescription, font: styles.fonts.sansSerif.subheadline.bold)
                .style(" left to spend this month on groceries and non-essential expenses, while still reaching your savings goal of ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(vm.savingsGoal, font: styles.fonts.sansSerif.subheadline.bold)
                .style(".\n\n", font: styles.fonts.sansSerif.subheadline.regular)
                .style("Note:\n", font: styles.fonts.sansSerif.subheadline.bold)
                .style("This is just an estimate based on your average living costs and monthly income. ", font: styles.fonts.sansSerif.subheadline.regular)
                .style("If your living costs this month are higher than average, or your income is lower than expected you may not reach your savings goal even if you spend within budget.", font: styles.fonts.sansSerif.subheadline.regular)
        case .exceeded:
            infoLabel.text = "🙁 You have exceeded your budget for this month. This may effect the time it takes to complete your goal."
            alertMessage = NSMutableAttributedString()
                .style("You have spent ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(vm.leftToSpend.shortDescriptionNoSign, font: styles.fonts.sansSerif.subheadline.bold)
                .style(" over your monthly budget for groceries and non-essential expenses. As a result you may not reach your savings goal of ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(vm.savingsGoal, font: styles.fonts.sansSerif.subheadline.bold)
                .style(".\n\n", font: styles.fonts.sansSerif.subheadline.regular)
                .style("Note:\n", font: styles.fonts.sansSerif.subheadline.bold)
                .style("This is just an estimate based on your average living costs and monthly income. ", font: styles.fonts.sansSerif.subheadline.regular)
                .style("If your living costs this month are higher than average, or your income is lower than expected you may not reach your savings goal even if you spend within budget.", font: styles.fonts.sansSerif.subheadline.regular)
        default:
            break
        }
    }

    @objc func onHelpButtonTap() {
        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            alertView.heightAnchor.constraint(equalToConstant: view.frame.height / 1.50)
        ])
    }
}

extension BudgetViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == staticTableView {
            return 1
        } else {
            if openConstraint?.priority == .required {
                return 2
            } else {
                return 1
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == staticTableView {
            return viewModel?.budgetDetails.count ?? 0
        } else {
            if openConstraint?.priority == .required {
                if section == 0 {
                    return viewModel?.discretionary.count ?? 0
                } else {
                    return viewModel?.nonDiscretionary.count ?? 0
                }
            } else {
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        if tableView == staticTableView {
            return 48
        } else {
            if openConstraint?.priority == .required {
                return UITableView.automaticDimension
            } else {
                return 24
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel, let styles else { return UITableViewCell() }

        if tableView == staticTableView, let cell = tableView.dequeueReusableCell(withIdentifier: BudgetStaticTableViewCell.reuseIdentifier, for: indexPath) as? BudgetStaticTableViewCell {
            cell.setData(data: vm.budgetDetails[indexPath.row])
            cell.style(styles: styles)

            return cell
        } else {
            if openConstraint?.priority == .required {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: BudgetOverlayTableViewCell.reuseIdentifier, for: indexPath) as? BudgetOverlayTableViewCell else { return UITableViewCell() }

                if indexPath.section == 0 {
                    cell.setData(data: vm.discretionary[indexPath.row], isDiscretionary: true)
                } else {
                    cell.setData(data: vm.nonDiscretionary[indexPath.row], isDiscretionary: false)
                }

                cell.style(styles: styles)

                return cell
            }

            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if openConstraint?.priority == UILayoutPriority(1.0) {
            guard let vm = viewModel, !vm.monthlyBreakdownIsEmpty else { return }
            overlayView.open()
        } else if tableView != staticTableView, indexPath.section == 0 {
            navigateToBudgetDetails(indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if openConstraint?.priority == .required {
            if tableView != staticTableView {
                guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BudgetOverlayHeaderView.reuseIdentifier) as? BudgetOverlayHeaderView else { return nil }

                if let viewModel, !viewModel.isSpendingAndCostsListEmpty {
                    if section == 0 {
                        headerView.setup(title: "Spending")
                    } else {
                        headerView.setup(title: "Living Costs")
                    }
                }

                return headerView
            }
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        if openConstraint?.priority == .required {
            if tableView != staticTableView {
                return 32
            }
        }
        return 0
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if openConstraint?.priority == .required {
            if tableView != staticTableView, section == 1 {
                return 40
            }
        }
        return 0
    }
}

extension BudgetViewController: TableOverlayViewDelegate {
    func overlay(_ overlay: TableOverlayView, isOpen: Bool) {
        openConstraint?.priority = isOpen ? .required : UILayoutPriority(1.0)
        overlay.tableView?.isScrollEnabled = isOpen
        
        if let viewModel, viewModel.isSpendingAndCostsListEmpty && isOpen {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
        }

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            overlay.tableView?.reloadData()
        }, completion: nil)
    }
}

extension BudgetViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
