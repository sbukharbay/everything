//
//  DashboardSettingsViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 04/08/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import LicensesViewController
import Amplitude
import UIKit
import Combine

class DashboardSettingsViewController: FloatingButtonController, Stylable, ErrorPresenter, ViewController {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var blurEffectView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.layer.cornerRadius = 30
        blur.clipsToBounds = true
        return blur
    }()

    private(set) lazy var profileIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "person.crop.circle")
        icon.tintColor = UIColor(hex: "#72F0F0")
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private(set) lazy var userName: BodyLabelDarkSemiBold = {
        let label = BodyLabelDarkSemiBold()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var accountDetailsButton: InlineButtonDark = {
        let button = InlineButtonDark()
        button.setTitle("Account Details", for: .normal)
        button.addTarget(self, action: #selector(accountButtonTap), for: .touchUpInside)
        return button
    }()

    private lazy var customNavBar: CustomNavigationBar = {  [weak self] in
        let navBar = CustomNavigationBar(title: "", rightButtonTitle: "Logout") {
            self?.backButtonHandle()
        } rightButtonAction: {
            self?.logoutButtonHandle()
        }
        navBar.removeBlurView()
        navBar.removeRightButtonChevron()
        return navBar
    }()

    private lazy var tableViewTop: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GetStartedTableViewCell.self, forCellReuseIdentifier: GetStartedTableViewCell.reuseIdentifier)
        return tableView
    }()

    private lazy var overlayView: TableOverlayView = {
        let view = TableOverlayView(frame: .zero)
        view.tabVisible = false
        view.heading = nil
        view.title = nil
        return view
    }()

    private(set) lazy var settingsLabel: FieldLabelLight = {
        let label = FieldLabelLight()
        label.text = "Settings"
        return label
    }()

    private(set) lazy var settingsIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "gearshape.fill")
        icon.tintColor = UIColor(hex: "2BA3B3")
        return icon
    }()

    private lazy var settingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [settingsIcon, settingsLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: settingsIcon)
        return stackView
    }()

    private lazy var tableViewBottom: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DashboardSettingsTableViewBottomCell.self, forCellReuseIdentifier: DashboardSettingsTableViewBottomCell.reuseIdentifier)
        return tableView
    }()

    private lazy var versionLabel: HeadlineLabelLight = {
        let label = HeadlineLabelLight()
        label.textAlignment = .center
        return label
    }()

    private var contentSizeMonitor: ContentSizeMonitor = .init()
    var viewModel: DashboardSettingsViewModel?
    private var styles: AppStyles?
    private var subscriptions = Set<AnyCancellable>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
        navigationController?.isNavigationBarHidden = true
        navigationController?.tabBarController?.tabBar.isHidden = true

        updateName()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top),

            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom)
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }

    func bind(styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        viewModel = DashboardSettingsViewModel()
        setupListeners()
        setupViews()
        
        bringFeedbackButton(String(describing: type(of: self)))
        
        self.styles = styles
        apply(styles: styles)
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
        
        // update api version text
        viewModel?.$apiVersion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] apiVersion in
                guard let self else { return }
                self.updateApiVersion(apiVersion: apiVersion)
            }
            .store(in: &subscriptions)
        
        // Listen for release of data in subject
        viewModel?.updateNameSubject
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] willUpdate in
                guard let self, willUpdate else { return }
                self.updateName()
            }
            .store(in: &subscriptions)
    }

    private func setupViews() {
        [backgroundImageView, blurEffectView, profileIcon, userName, accountDetailsButton, tableViewTop, overlayView, settingStackView, tableViewBottom, versionLabel, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 8),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),

            profileIcon.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            profileIcon.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            profileIcon.heightAnchor.constraint(equalToConstant: 55),
            profileIcon.widthAnchor.constraint(equalToConstant: 55),

            userName.topAnchor.constraint(equalTo: profileIcon.bottomAnchor, constant: 16),
            userName.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            userName.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 8),
            userName.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -8),

            accountDetailsButton.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            accountDetailsButton.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            tableViewTop.topAnchor.constraint(equalTo: accountDetailsButton.bottomAnchor, constant: 16),
            tableViewTop.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tableViewTop.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            tableViewTop.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -260),

            overlayView.topAnchor.constraint(equalTo: tableViewTop.bottomAnchor, constant: 24),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            settingStackView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 48),
            settingStackView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),

            settingsIcon.heightAnchor.constraint(equalToConstant: 25),
            settingsIcon.widthAnchor.constraint(equalToConstant: 25),

            tableViewBottom.topAnchor.constraint(equalTo: settingStackView.bottomAnchor, constant: 16),
            tableViewBottom.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            tableViewBottom.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            tableViewBottom.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -24),

            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            versionLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor)
        ])
    }
    
    func reload() {
        Task {
            await viewModel?.getUserName()
        }
    }

    func update() {
        tableViewTop.reloadData()
        tableViewBottom.reloadData()
    }

    func updateName() {
        if let vm = viewModel {
            let firstName = vm.firstName
            let lastName = vm.lastName
            userName.text = firstName + " " + lastName
        }
    }

    func updateApiVersion(apiVersion: String) {
        versionLabel.text = "affordIQ \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Version Unavailable")" + " API \(apiVersion)"
    }

    @objc private func accountButtonTap() {
        navigateToAccountDetails()
    }

    @objc private func backButtonHandle() {
        switch navigationController?.tabBarController?.selectedIndex {
        case 0:
            if let navigationController, let vc = navigationController.viewControllers.last(where: { $0.isKind(of: HomeViewController.self) }), let settingsVC = vc as? HomeViewController {
                settingsVC.resume()
                navigationController.popToViewController(settingsVC, animated: true)
                return
            }
        case 1:
            if let navigationController, let vc = navigationController.viewControllers.last(where: { $0.isKind(of: GoalsViewController.self) }), let settingsVC = vc as? GoalsViewController {
                settingsVC.resume()
                navigationController.popToViewController(settingsVC, animated: true)
                return
            }
        case 2:
            if let navigationController, let vc = navigationController.viewControllers.last(where: { $0.isKind(of: BudgetViewController.self) }), let settingsVC = vc as? BudgetViewController {
                settingsVC.resume()
                navigationController.popToViewController(settingsVC, animated: true)
                return
            }
        case 3:
            if let navigationController, let vc = navigationController.viewControllers.last(where: { $0.isKind(of: AffordabilityMainViewController.self) }), let settingsVC = vc as? AffordabilityMainViewController {
                settingsVC.resume()
                navigationController.popToViewController(settingsVC, animated: true)
                return
            }
        default:
            break
        }
        
        navigationController?.popViewController(animated: true)
    }

    // TODO: 
    @objc private func logoutButtonHandle() {
        guard let viewModel else { return }
        
        viewModel.userSession.logout { [weak self] error in
            if let error = error {
                switch error {
                case SessionError.cancelled:
                    break
                default:
                    self?.present(error: error)
                }
                return
            }
        }

        Amplitude.instance().logEvent("LOGOUT")
        viewModel.cleanUserApp()
        navigationController?.viewControllers = []
        let rootCoordinator = RootCoordinator()
        rootCoordinator.start()
    }
}

// MARK: - Navigation
extension DashboardSettingsViewController {
    func navigateToTerms() {
        if let presenter = navigationController {
            let coordinator = HelpAndSupportCoordinator(presenter: presenter, isTerms: true)
            coordinator.start()
        }
    }
    
    func navigateToHelp() {
        if let presenter = navigationController {
            let coordinator = HelpAndSupportCoordinator(presenter: presenter)
            coordinator.start()
        }
    }
    
    func navigateToSpending() {
        if let presenter = navigationController {
            let coordinator = SpendingSummaryCoordinator(presenter: presenter, getStartedType: nil, isSettings: true)
            coordinator.start()
        }
    }
    
    func navigateToLinkedAccounts() {
        if let presenter = navigationController {
            let accountsCoordinator = AccountsCoordinator(presenter: presenter, isBack: true, isSettings: true)
            accountsCoordinator.start()
        }
    }
    
    func navigateToAccountDetails() {
        if let presenter = navigationController {
            let registrationCoordinator = RegistrationCoordinator(presenter: presenter, isSettings: true)
            registrationCoordinator.start()
        }
    }
    
    func navigateToIncome() {
        if let presenter = navigationController, let viewModel {
            let confirmIncomeCoordinator = ConfirmIncomeCoordinator(presenter: presenter, incomeData: viewModel.incomeData, isBack: true, isSettings: true)
            confirmIncomeCoordinator.start()
        }
    }
    
    func navigateToSavings() {
        if let presenter = navigationController, let styles {
            let savingsGoalCoordinator = DepositCoordinator(presenter: presenter, targetHeight: nil, isSettings: true)

            let imageView = styles.backgroundImages.defaultImage.imageView
            imageView.frame = presenter.view.bounds
            presenter.view.insertSubview(imageView, at: 0)

            savingsGoalCoordinator.start()
        }
    }
    
    func navigateToAcknowledgements() {
        perform(action: { viewController in
            if let presenter = viewController.navigationController {
                let vc = LicensesViewController()
                let styles = AppStyles.shared
                vc.loadPlist(uiBundle, resourceName: "Credits")
                
                presenter.isNavigationBarHidden = false
                
                let appearance = UINavigationBarAppearance()
                appearance.titleTextAttributes = [
                    .foregroundColor: UIColor.white,
                    .font: styles.fonts.sansSerif.title3
                ]
                appearance.backgroundColor = styles.colors.buttons.primaryDark.text.color
                
                presenter.navigationBar.scrollEdgeAppearance = appearance
                presenter.navigationBar.standardAppearance = appearance
                presenter.navigationBar.tintColor = styles.colors.buttons.primaryDark.fill.color
                
                presenter.pushViewController(vc, animated: true)
            }
        })
    }
}

extension DashboardSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let vm = viewModel else { return 0 }

        if tableView == tableViewTop {
            return vm.settingsData.count
        } else {
            return vm.tableData.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewTop {
            guard let cell = tableViewTop.dequeueReusableCell(withIdentifier: GetStartedTableViewCell.reuseIdentifier, for: indexPath) as? GetStartedTableViewCell, let vm = viewModel else { return UITableViewCell() }
            cell.dashboardSettingsData(with: vm.settingsData[indexPath.row])
            return cell
        } else {
            guard
                let bottomCell = tableViewBottom.dequeueReusableCell(withIdentifier: DashboardSettingsTableViewBottomCell.reuseIdentifier, for: indexPath) as? DashboardSettingsTableViewBottomCell,
                let vm = viewModel else { return UITableViewCell() }
            bottomCell.titleLabel.text = vm.tableData[indexPath.row]
            return bottomCell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewTop {
            switch indexPath.row {
            case 0:
                return navigateToIncome()
            case 1:
                return navigateToSavings()
            case 2:
                return navigateToSpending()
            case 3:
                return navigateToLinkedAccounts()
            default:
                return navigateToHelp()
            }
        } else {
            switch indexPath.row {
            case 0:
                return navigateToTerms()
            default:
                return navigateToAcknowledgements()
            }
        }
    }
}

extension DashboardSettingsViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
