//
//  AccountsViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 28/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

enum AccountPosition {
    case top
    case middle
    case bottom
    case single
}

class AccountsViewController: FloatingButtonController, Stylable, ViewController {
    private(set) lazy var backgroundImageView: BackgroundImageView = .init(frame: view.frame)
    
    private(set) lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Linked Accounts", rightButtonTitle: "Next") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: { [weak self] in
            if self?.viewModel?.addedSavings == true {
                self?.navigateBackToSavings()
            } else {
                self?.showNextScreen()
            }
        }
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()
    
    private(set) lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(AccountCellView.self)
        view.contentInset.top += 16
        view.contentInset.bottom -= 16
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var reconsentButton: WarningButtonDark = {
        let view = WarningButtonDark()
        view.setTitle("Renew Consent", for: .normal)
        view.addTarget(self, action: #selector(renewConsent), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var addAccountsButton: PrimaryButtonDark = {
        let view = PrimaryButtonDark()
        view.setTitle("Add More Accounts", for: .normal)
        view.addTarget(self, action: #selector(addMoreAccounts), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var buttonVStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    var viewModel: AccountsViewModel?
    var authorizationCoordinator: OpenBankingAuthorizationCoordinator?
    
    private var styles: AppStyles?
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListeners()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewDidLayoutSubviews() {
        setCustomNavBarConstraints()

        navigationController?.isNavigationBarHidden = true
    }

    func bind(
        isBack: Bool?,
        getStartedType: GetStartedViewType? = nil,
        addedSavings: Bool? = nil,
        isSettings: Bool = false,
        styles: AppStyles = AppStyles.shared
    ) {
        self.styles = styles
        apply(styles: styles)

        if viewModel == nil {
            viewModel = AccountsViewModel(getStartedType: getStartedType, addedSavings: addedSavings, isSettings: isSettings)
        }

        if let back = isBack {
            if back {
                customNavBar.hideRightButton(hide: true)
            }
        } else {
            customNavBar.hideRightButton(hide: true)
            customNavBar.hideLeftButton(hide: true)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }

        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    private func setupListeners() {
        viewModel?.$reconsent
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] reconsent in
                guard let self else { return }
                self.reconsentButton.isHidden = !reconsent
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let navigationController = self?.navigationController else { return }
                if isLoading && !BusyView.shared.isPresented {
                    BusyView.shared.show(
                        navigationController: navigationController,
                        title: NSLocalizedString("Preparing Data", bundle: uiBundle, comment: "Preparing Data"),
                        fullScreen: false
                    )
                } else {
                    BusyView.shared.hide(success: true)
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$present
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                self.tableView.reloadData()
            }
            .store(in: &subscriptions)
    }

    func reload() {
        viewModel?.load()
    }
    
    @objc private func addMoreAccounts(_: Any?) {
        if let navigationController = navigationController, let viewModel = viewModel {
            let chooseProviderCoordinator = ChooseProviderCoordinator(presenter: navigationController, addedSavings: viewModel.addedSavings, isSettings: viewModel.isSettings, getStartedType: viewModel.getStartedType)
            chooseProviderCoordinator.start()
        }
    }
    
    @objc private func renewConsent(_ sender: Any?) {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = RenewConsentCoordinator(presenter: presenter, accounts: viewModel.accountsAndConsents, preReconsentType: .accounts)
                coordinator.start()
            })
        }
    }
    
    func navigateBackToSavings() {
        perform(action: { viewController in
            if let presenter = viewController.navigationController, let styles {
                let savingsGoalCoordinator = DepositCoordinator(presenter: presenter, targetHeight: nil, showNextButton: true, isSettings: false)
                
                let imageView = styles.backgroundImages.defaultImage.imageView
                imageView.frame = presenter.view.bounds
                presenter.view.insertSubview(imageView, at: 0)
                
                savingsGoalCoordinator.start()
            }
        })
    }
    
    func showNextScreen() {
        perform(action: { viewController in
            if let presenter = viewController.navigationController, let viewModel {
                presenter.dismiss(animated: true, completion: {
                    let coordinator = AddMoreAccountsCoordinator(presenter: presenter, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                    
                    coordinator.start()
                })
            }
        })
    }
    
    func deleteCell(at indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
}

extension AccountsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // we have two types of accounts: Current and saving accounts
        return viewModel?.present.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.present[section].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(AccountCellView.self, for: indexPath)
        let row = viewModel.present[indexPath.section][indexPath.row]
        
        let lastIndex = viewModel.present[indexPath.section].count - 1
        let sectionTitle = switch indexPath.section {
        case 1: "Current Accounts"
        case 2: "Saving Accounts"
        default: "Accounts"
        }
        
        if viewModel.present[indexPath.section].count == 1 {
            cell.configureShape(position: .single)
            cell.configureAccountCell(row, header: sectionTitle)
        } else if indexPath.row == 0 {
            cell.configureShape(position: .top)
            cell.configureAccountCell(row, header: sectionTitle)
        } else if indexPath.row == lastIndex {
            cell.configureShape(position: .bottom)
            cell.configureAccountCell(row)
        } else {
            cell.configureShape(position: .middle)
            cell.configureAccountCell(row)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
}

extension AccountsViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navigationController = navigationController,
           let viewModel {
            let selectedAccount = viewModel.present[indexPath.section][indexPath.row]
            let filteredAccounts = viewModel.uniqueAccounts.filter { $0.institutionId == selectedAccount.institutionId }
            
            let coordinator = AccountDetailsCoordinator(
                presenter: navigationController,
                account: selectedAccount,
                delegate: self,
                institutionAccounts: filteredAccounts,
                isLast: selectedAccount.accountType == .current ? viewModel.isLastCurrentAccount : viewModel.isLastSavingAccount
            )
            coordinator.start()
        }
    }
}

extension AccountsViewController: AccountDeletionDelegate {
    func deleteAccount(with accountID: String) {
        guard let indexPath = viewModel?.findAccount(with: accountID) else { return }
        deleteCell(at: indexPath)
    }
}

extension AccountsViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
