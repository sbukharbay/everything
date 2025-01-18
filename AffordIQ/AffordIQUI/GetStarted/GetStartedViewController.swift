//
//  GetStartedViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.10.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class GetStartedViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        if viewModel?.viewType == .initial {
            imageView.image = UIImage(named: "milestone_opal_background", in: uiBundle, compatibleWith: nil)
        } else {
            imageView.image = UIImage(named: "design_time_background", in: Bundle(for: BackgroundImageView.self), compatibleWith: nil)
        }
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()

    private let headerLabel: TitleLabelBlue = {
        let label = TitleLabelBlue()
        label.text = "GET STARTED"
        return label
    }()

    private let descriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Let's set-up affordIQ"
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(GetStartedTableViewCell.self, forCellReuseIdentifier: GetStartedTableViewCell.reuseIdentifier)
        tableView.register(GetStartedHeaderView.self, forHeaderFooterViewReuseIdentifier: GetStartedHeaderView.reuseIdentifier)
        return tableView
    }()

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "", rightButtonTitle: "Next") { [weak self] in
            self?.handleBack()
        } rightButtonAction: { [weak self] in
            self?.handleNext()
        }
        return navBar
    }()

    private var viewModel: GetStartedViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()

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
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    func bind(type: GetStartedViewType, isBackAvailable: Bool = true) {
        loadViewIfNeeded()

        let vm = GetStartedViewModel()
        vm.viewType = type

        if !isBackAvailable {
            customNavBar.hideLeftButton(hide: true)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }

        viewModel = vm
        setupViews()
        apply(styles: AppStyles.shared)
    }

    fileprivate func setupViews() {
        var views = [backgroundImageView, blurEffectView, tableView, customNavBar]
        var constraints = [
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),

            tableView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16)
        ]

        switch viewModel?.viewType {
        case .initial:
            views.append(contentsOf: [headerLabel, descriptionLabel])
            constraints.append(contentsOf:
                [headerLabel.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 32),
                 headerLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
                 headerLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -32),
                 descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
                 descriptionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
                 descriptionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -32),
                 tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
                 tableView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 56)])
        case .linkedBankAccounts, .registered:
            constraints.append(contentsOf:
                [tableView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 12),
                 tableView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 48)])
        default:
            constraints.append(contentsOf:
                [tableView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 12),
                 tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)])
        }

        views.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        if viewModel?.viewType != .initial {
            bringFeedbackButton(String(describing: type(of: self)))
        }

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func handleNext() {
        guard let viewModel else { return }
        switch viewModel.viewType {
        case .initial:
            register()
        case .registered:
            linkAccounts()
        case .linkedBankAccounts:
            showSetCompass()
        case .income:
            showSavings(true)
        case .savings:
            showAlfiLoader()
        case .spending:
            showOwnFuture()
        case .goal:
            showAlfiRocket()
        }
    }

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    func navigateTo(current: IndexPath, last: IndexPath) {
        if current <= last {
            if current.section == 0, current.row == 0 {
                register()
            } else if current.section == 0, current.row == 1 {
                backToListOfLinkedAccounts()
            } else if current.section == 1, current.row == 0 {
                backToIncomeConfirmation()
            } else if current.section == 1, current.row == 1 {
                showSavings(false)
            } else if current.section == 1, current.row == 2 {
                showSpendSummary()
            } else if current.section == 2, current.row == 0 {
                showGoalBreakdown()
            }
        }
    }
    
    func register() {
        if let presenter = navigationController {
            let registrationCoordinator = RegistrationCoordinator(presenter: presenter)
            registrationCoordinator.start()
        }
    }

    func linkAccounts() {
        if let presenter = navigationController {
            let linkCoordinator = LinkAccountsInformationCoordinator(presenter: presenter)
            linkCoordinator.start()
        }
    }

    func backToListOfLinkedAccounts() {
        if let presenter = navigationController, let viewModel {
            let accountsCoordinator = AccountsCoordinator(presenter: presenter, isBack: true, getStartedType: viewModel.viewType)
            accountsCoordinator.start()
        }
    }

    func showSavings(_ showNextButton: Bool) {
        if let presenter = navigationController {
            let imageView = AppStyles.shared.backgroundImages.defaultImage.imageView
            imageView.frame = presenter.view.bounds
            presenter.view.insertSubview(imageView, at: 0)

            let depositCoordinator = DepositCoordinator(presenter: presenter,
                                                        targetHeight: nil,
                                                        showNextButton: showNextButton)
            depositCoordinator.start()
        }
    }

    func showSetCompass() {
        if let presenter = navigationController {
            let coordinator = MilestoneInformationCoordinator(presenter: presenter, type: .ownYourFinances)
            coordinator.start()
        }
    }

    func showGoalBreakdown() {
        if let presenter = navigationController, let viewModel {
            let coordinator = SetAGoalCheckPointCoordinator(presenter: presenter, type: .dashboard, getStartedType: viewModel.viewType)
            coordinator.start()
        }
    }

    func backToIncomeConfirmation() {
        if let presenter = navigationController, let viewModel {
            let coordinator = ConfirmIncomeCoordinator(presenter: presenter, incomeData: viewModel.incomeData, getStartedType: viewModel.viewType, isBack: true)
            coordinator.start()
        }
    }

    func showOwnFuture() {
        if let presenter = navigationController {
            let coordinator = MilestoneInformationCoordinator(presenter: presenter, type: .ownYourFuture)
            coordinator.start()
        }
    }

    func showSpendSummary() {
        if let presenter = navigationController, let viewModel {
            let coordinator = SpendingSummaryCoordinator(presenter: presenter, getStartedType: viewModel.viewType)
            coordinator.start()
        }
    }

    func showAlfiLoader() {
        if let presenter = navigationController, let viewModel {
            let coordinator = AlfiLoaderCoordinator(presenter: presenter, getStartedType: viewModel.viewType)
            coordinator.start()
        }
    }

    func showAlfiRocket() {
        if let presenter = navigationController {
            let coordinator = OnboardingCompleteCoordinator(presenter: presenter)
            coordinator.start()
        }
    }
}

extension GetStartedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        switch viewModel?.viewType {
        case .initial, .registered:
            return 1
        case .linkedBankAccounts, .income, .savings:
            return 2
        case .spending:
            return 3
        case .goal:
            return 4
        default:
            return 0
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel?.getStartedData.count ?? 0
        } else if section == 1 {
            switch viewModel?.viewType {
            case .linkedBankAccounts:
                return 0
            default:
                return viewModel?.ownYourFinancesData.count ?? 0
            }
        } else if section == 2 {
            switch viewModel?.viewType {
            case .spending:
                return 0
            default:
                return viewModel?.ownYourFutureData.count ?? 0
            }
        } else {
            return 0
        }
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch viewModel?.viewType {
        case .initial:
            return nil
        default:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: GetStartedHeaderView.reuseIdentifier) as? GetStartedHeaderView else { return nil }

            if section == 0 {
                headerView.setup(title: "GET STARTED")
            } else if section == 1 {
                switch viewModel?.viewType {
                case .linkedBankAccounts:
                    headerView.setup(title: "Nice work!\nYou are now setup.")
                default:
                    headerView.setup(title: "OWN YOUR FINANCES")
                }
            } else if section == 2 {
                switch viewModel?.viewType {
                case .spending:
                    headerView.setup(title: "Excellent!\nYou have taken ownership of your finances.")
                default:
                    headerView.setup(title: "OWN YOUR FUTURE")
                }
            } else if section == 3 {
                headerView.setup(title: "Fantastic work! You have started to take control of your future.")
            }

            headerView.apply(styles: AppStyles.shared)

            return headerView
        }
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch viewModel?.viewType {
        case .initial:
            return 0
        case .goal:
            if section == 3 {
                return 72
            }
            return 40
        default:
            return 56
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GetStartedTableViewCell.reuseIdentifier, for: indexPath) as? GetStartedTableViewCell, let vm = viewModel else { return UITableViewCell() }

        switch viewModel?.viewType {
        case .initial:
            cell.setupData(with: vm.getStartedData[indexPath.row], clickable: false)
        case .registered:
            if indexPath.row == 0 {
                cell.setupData(with: vm.getStartedData[indexPath.row], clickable: true)
            } else {
                cell.setupData(with: vm.getStartedData[indexPath.row], clickable: false)
            }
        case .linkedBankAccounts:
            cell.setupData(with: vm.getStartedData[indexPath.row], clickable: true)
        case .income:
            if indexPath.section == 0 {
                cell.setupData(with: vm.getStartedData[indexPath.row], clickable: true)
            } else {
                if indexPath.row == 0 {
                    cell.setupData(with: vm.ownYourFinancesData[indexPath.row], clickable: true)
                } else {
                    cell.setupData(with: vm.ownYourFinancesData[indexPath.row], clickable: false)
                }
            }
        case .savings:
            if indexPath.section == 0 {
                cell.setupData(with: vm.getStartedData[indexPath.row], clickable: true)
            } else {
                if indexPath.row == 0 || indexPath.row == 1 {
                    cell.setupData(with: vm.ownYourFinancesData[indexPath.row], clickable: true)
                } else {
                    cell.setupData(with: vm.ownYourFinancesData[indexPath.row], clickable: false)
                }
            }
        case .spending:
            if indexPath.section == 0 {
                cell.setupData(with: vm.getStartedData[indexPath.row], clickable: true)
            } else if indexPath.section == 1 {
                cell.setupData(with: vm.ownYourFinancesData[indexPath.row], clickable: true)
            }
        case .goal:
            if indexPath.section == 0 {
                cell.setupData(with: vm.getStartedData[indexPath.row], clickable: true)
            } else if indexPath.section == 1 {
                cell.setupData(with: vm.ownYourFinancesData[indexPath.row], clickable: true)
            } else if indexPath.section == 2 {
                cell.setupData(with: vm.ownYourFutureData[indexPath.row], clickable: true)
            }
        default:
            break
        }

        cell.style(styles: AppStyles.shared)

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel?.viewType {
        case .initial:
            break
        case .registered:
            navigateTo(current: indexPath, last: IndexPath(row: 0, section: 0))
        case .linkedBankAccounts:
            navigateTo(current: indexPath, last: IndexPath(row: 1, section: 0))
        case .income:
            navigateTo(current: indexPath, last: IndexPath(row: 0, section: 1))
        case .savings:
            navigateTo(current: indexPath, last: IndexPath(row: 1, section: 1))
        case .spending:
            navigateTo(current: indexPath, last: IndexPath(row: 2, section: 1))
        case .goal:
            navigateTo(current: indexPath, last: IndexPath(row: 0, section: 2))
        default:
            break
        }
    }
}

extension GetStartedViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
