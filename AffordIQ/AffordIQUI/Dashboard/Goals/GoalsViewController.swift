//
//  GoalsViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 07.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine
import AffordIQNetworkKit

class GoalsViewController: FloatingButtonController, Stylable, ErrorPresenter, DashboardBindable, ViewController {
    private(set) lazy var topBlurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private(set) lazy var monthCircleMeterView: CircularMeterView = {
        let meter = CircularMeterView(frame: .zero)
        meter.numberOfSegments = 16
        meter.lineWidth = 6
        meter.isClockwise = true
        return meter
    }()

    private(set) lazy var monthLabel: DashboardLargeTitle = {
        let label = DashboardLargeTitle()
        label.text = ""
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var affordableUntilLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Months until affordable"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [monthLabel, affordableUntilLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var depositProgressBar: UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.layer.cornerRadius = 5
        bar.layer.masksToBounds = true
        bar.trackTintColor = UIColor(white: 1, alpha: 0.3)
        bar.progressImage = UIImage(named: "progress_bar", in: uiBundle, compatibleWith: nil)
        bar.setProgress(0.5, animated: false)
        return bar
    }()

    private(set) lazy var depositPercentageLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Deposit"
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var currentDepositTitle: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Current"
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var currentDepositAmount: BodyLabelDarkSemiBold = {
        let label = BodyLabelDarkSemiBold()
        label.text = ""
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var currentDepositStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentDepositTitle, currentDepositAmount])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var currentTargetTitle: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Target"
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var currentTargetAmount: BodyLabelDarkSemiBold = {
        let label = BodyLabelDarkSemiBold()
        label.text = ""
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var currentTargetStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentTargetTitle, currentTargetAmount])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var amountsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentDepositStackView, currentTargetStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var depositLeftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [depositPercentageLabel, depositProgressBar])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private(set) lazy var depositIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "deposit_goal", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private(set) lazy var depositStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [depositIcon, depositLeftStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: depositIcon)
        return stackView
    }()

    private(set) lazy var propertyTitle: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Property"
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var propertyAmount: BodyLabelDarkSemiBold = {
        let label = BodyLabelDarkSemiBold()
        label.text = ""
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var propertyLeftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [propertyTitle, propertyAmount])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private(set) lazy var propertyIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "property", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private(set) lazy var propertyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [propertyIcon, propertyLeftStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: propertyIcon)
        return stackView
    }()

    private(set) lazy var savingsLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Savings"
        label.textAlignment = .left
        return label
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

    private(set) lazy var savingsAmountLabel: BodyLabelDarkSemiBold = {
        let label = BodyLabelDarkSemiBold()
        label.text = ""
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var savingsLeftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [savingsLabel, savingsAmountLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private(set) lazy var savingsImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "savings", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private(set) lazy var savingsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [savingsImageView, savingsLeftStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: savingsImageView)
        return stackView
    }()

    private(set) lazy var editButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()

    private(set) lazy var overlayView: TableOverlayView = {
        let view = TableOverlayView(frame: .zero)
        view.tabVisible = true
        view.heading = nil
        view.title = nil
        view.delegate = self
        return view
    }()

    private var viewModel: GoalsViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var openConstraint: NSLayoutConstraint?
    private var subscriptions = Set<AnyCancellable>()
    private var styles: AppStyles?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        let height = view.frame.height / 5.5

        NSLayoutConstraint.activate([
            monthCircleMeterView.heightAnchor.constraint(equalToConstant: height),
            monthCircleMeterView.widthAnchor.constraint(equalToConstant: height),

            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom)
        ])
    }

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()

    func resume() {
        viewModel?.resume()
    }

    func bind(styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()
        
        viewModel = GoalsViewModel()

        setupNavigationBar()

        if let tableView = overlayView.tableView {
            createDataSource(tableView: tableView)
        }

        setupViews()
        setupListeners()
        self.styles = styles
        apply(styles: styles)

        topBlurEffectView.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true

        bringFeedbackButton(String(describing: type(of: self)))
        setupSwipeGesture()
    }

    private func setupNavigationBar() {
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

    func setupViews() {
        [topBlurEffectView, monthCircleMeterView, topStackView, depositStackView, amountsStackView, propertyStackView, savingsStackView, editButton, overlayView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        openConstraint = overlayView.topAnchor.constraint(equalTo: monthCircleMeterView.topAnchor, constant: -20)
        openConstraint?.priority = UILayoutPriority(1.0)
        openConstraint?.isActive = true

        NSLayoutConstraint.activate([
            topBlurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBlurEffectView.bottomAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 24),

            monthCircleMeterView.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor, constant: 24),
            monthCircleMeterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            topStackView.centerXAnchor.constraint(equalTo: monthCircleMeterView.centerXAnchor),
            topStackView.centerYAnchor.constraint(equalTo: monthCircleMeterView.centerYAnchor),
            topStackView.leadingAnchor.constraint(equalTo: monthCircleMeterView.leadingAnchor, constant: 8),
            topStackView.trailingAnchor.constraint(equalTo: monthCircleMeterView.trailingAnchor, constant: -8),

            depositStackView.topAnchor.constraint(equalTo: monthCircleMeterView.bottomAnchor, constant: 24),
            depositStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 20),
            depositStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),

            depositProgressBar.heightAnchor.constraint(equalToConstant: 10),

            depositIcon.heightAnchor.constraint(equalToConstant: 34),
            depositIcon.widthAnchor.constraint(equalToConstant: 34),

            amountsStackView.topAnchor.constraint(equalTo: depositStackView.bottomAnchor, constant: 8),
            amountsStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 60),
            amountsStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),

            propertyStackView.topAnchor.constraint(equalTo: amountsStackView.bottomAnchor, constant: 16),
            propertyStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 20),
            propertyStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),

            propertyIcon.heightAnchor.constraint(equalToConstant: 34),
            propertyIcon.widthAnchor.constraint(equalToConstant: 34),

            savingsStackView.topAnchor.constraint(equalTo: propertyStackView.bottomAnchor, constant: 16),
            savingsStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 20),
            savingsStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),

            savingsImageView.heightAnchor.constraint(equalToConstant: 34),
            savingsImageView.widthAnchor.constraint(equalToConstant: 34),

            editButton.topAnchor.constraint(equalTo: savingsStackView.bottomAnchor, constant: 24),
            editButton.heightAnchor.constraint(equalToConstant: 40),
            editButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
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
                guard let self, let error else { return }
                self.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.$willUpdateBottom
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willUpdate in
                if let self, willUpdate {
                    self.updateBottom()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$mortgageLimits
            .receive(on: DispatchQueue.main)
            .sink { [weak self] limits in
                if let limits, let self {
                    self.updateTop(limits)
                }
            }
            .store(in: &subscriptions)
    }

    @objc private func tapToDismiss(_: UITapGestureRecognizer) {
        if openConstraint?.priority == .required {
            overlayView.close()
        }
    }

    func updateBottom() {
        asyncIfRequired { [weak self] in
            self?.overlayView.tableView?.reloadData()
        }
    }

    func updateTop(_ mortgageLimits: PropertyGoalAndMortgageLimitsResponse) {
        guard let monthsCount = mortgageLimits.monthsUntilAffordable else {
            monthLabel.text = "?"
            monthCircleMeterView.progress = 1.0
            return
        }

        let deposit = (1 - (mortgageLimits.depositGoal?.loanToValue ?? 0)) * 100
        depositProgressBar.setProgress(viewModel?.progressBarAmount ?? 1, animated: false)

        let current = mortgageLimits.mortgageLimits?.currentDeposit
        let target = mortgageLimits.targetDeposit

        currentDepositAmount.text = current?.shortDescription ?? "N/A"
        currentTargetAmount.text = target?.shortDescription ?? "N/A"
        depositPercentageLabel.text = "Deposit (" + Int(deposit.floatValue).description + "%)"

        propertyAmount.text = mortgageLimits.propertyGoal?.propertyValue?.shortDescription ?? "N/A"
        savingsAmountLabel.text = (mortgageLimits.savingsGoal?.monthlySavingsAmount?.shortDescription ?? "N/A") + "/m"

        monthLabel.text = monthsCount > 36 ? "36+" : monthsCount.description
        
        switch monthsCount {
        case 0:
            monthLabel.text = "NOW"
            affordableUntilLabel.text = "Affordable"
        case 1:
            affordableUntilLabel.text = "Month until affordable"
        default:
            affordableUntilLabel.text = "Months until affordable"
        }
        
        monthCircleMeterView.progress = monthsCount >= 48 ? 0 : (48 - Float(monthsCount)) / 48
    }

    @objc func leftButtonHandle() {
        showSettings()
    }

    @objc func rightButtonHandle() {
        perform { viewController in
            if let presenter = viewController.navigationController {
                presenter.dismiss(animated: true, completion: {
                    let coordinator = NotificationsCoordinator(presenter: presenter)
                    coordinator.start()
                })
            }
        }
    }

    @objc private func handleEdit() {
        editGoals()
    }
    
    func showSettings() {
        perform(action: { viewController in
            if let presenter = viewController.navigationController {
                presenter.dismiss(animated: true, completion: {
                    let coordinator = DashboardSettingsCoordinator(presenter: presenter)
                    coordinator.start()
                })
            }
        })
    }
    
    func editGoals() {
        perform(action: { viewController in
            if let presenter = viewController.navigationController {
                presenter.dismiss(animated: true, completion: {
                    let coordinator = SetAGoalCheckPointCoordinator(presenter: presenter, type: .dashboard)
                    coordinator.start()
                })
            }
        })
    }

    func createDataSource(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.register(AffordabilityMainOverlayTableViewCell.self, forCellReuseIdentifier: AffordabilityMainOverlayTableViewCell.reuseIdentifier)
        tableView.register(AffordabilityMainOverlayHeaderView.self, forHeaderFooterViewReuseIdentifier: AffordabilityMainOverlayHeaderView.reuseIdentifier)
        tableView.register(AffordabilityMainOverlayFooterView.self, forHeaderFooterViewReuseIdentifier: AffordabilityMainOverlayFooterView.reuseIdentifier)
        tableView.sectionHeaderHeight = 0
    }
}

extension GoalsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if openConstraint?.priority == .required {
            return viewModel?.overlayData[1].details.count ?? 0
        } else {
            return viewModel?.overlayData.count ?? 0
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel, let cell = tableView.dequeueReusableCell(withIdentifier: AffordabilityMainOverlayTableViewCell.reuseIdentifier, for: indexPath) as? AffordabilityMainOverlayTableViewCell else { return UITableViewCell() }

        if let styles {
            cell.style(styles: styles)
        }
        cell.chevronIcon.isHidden = true

        if openConstraint?.priority == .required {
            let icon = UIImage(named: vm.overlayData[1].details[indexPath.row].icon, in: uiBundle, compatibleWith: nil) ?? UIImage(systemName: vm.overlayData[1].details[indexPath.row].icon)!
            cell.icon.image = icon
            cell.titleLabel.text = vm.overlayData[1].details[indexPath.row].title
            cell.valueLabel.text = vm.overlayData[1].details[indexPath.row].value
        } else {
            let icon = UIImage(named: vm.overlayData[indexPath.row].info.icon, in: uiBundle, compatibleWith: nil) ?? UIImage(systemName: vm.overlayData[indexPath.row].info.icon)!
            cell.icon.image = icon
            cell.titleLabel.text = vm.overlayData[indexPath.row].info.title
            if vm.overlayData[indexPath.row].details.isEmpty {
                cell.valueLabel.text = vm.overlayData[indexPath.row].info.value
            } else {
                cell.chevronIcon.isHidden = false
                cell.valueLabel.text = ""
            }
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if openConstraint?.priority == UILayoutPriority(1.0) {
                overlayView.open()
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection _: Int) -> UIView? {
        if openConstraint?.priority == .required {
            guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AffordabilityMainOverlayFooterView.reuseIdentifier) as? AffordabilityMainOverlayFooterView, let styles else { return nil }

            footerView.setup(title: "Note: These are rough estimates to serve as a guide only. The exact details of the mortgages that will be available to you when you apply will vary.")
            footerView.style(styles: styles)

            return footerView
        } else {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        if openConstraint?.priority == .required {
            return UITableView.automaticDimension
        } else {
            return view.safeAreaInsets.bottom
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        if openConstraint?.priority == .required {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AffordabilityMainOverlayHeaderView.reuseIdentifier) as? AffordabilityMainOverlayHeaderView, let vm = viewModel else { return nil }

            let icon: UIImage = .init(named: vm.overlayData[1].info.icon, in: uiBundle, compatibleWith: nil) ?? UIImage(systemName: vm.overlayData[1].info.icon)!
            headerView.setup(title: vm.overlayData[1].info.title, icon: icon)
            if let styles {
                headerView.style(styles: styles)
            }
            return headerView
        }
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        if openConstraint?.priority == .required {
            return UITableView.automaticDimension
        }
        return 0
    }
}

extension GoalsViewController: TableOverlayViewDelegate {
    func overlay(_ overlay: TableOverlayView, isOpen: Bool) {
        openConstraint?.priority = isOpen ? .required : UILayoutPriority(1.0)
        overlay.tableView?.isScrollEnabled = isOpen

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            overlay.tableView?.reloadData()
        }, completion: nil)
    }
}

extension GoalsViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
