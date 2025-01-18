//
//  LinkAccountsViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 02/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import Amplitude
import Combine
import UIKit

class LinkAccountsViewController: FloatingButtonController, Stylable, TableDataProvider, ErrorPresenter {
    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Link Accounts", rightButtonTitle: "Save") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: { [weak self] in
            self?.save()
        }
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()

    typealias SectionType = InstitutionAccount.AccountType
    typealias ItemType = LinkAccountsItem

    struct LinkAccountsItem: Equatable, Hashable {
        let account: InstitutionAccount
        var isSelected: Bool = true
    }

    @IBOutlet var accounts: UITableView?

    var saveButtonIsEnabled = false
    var dataSource: DataSourceType?
    var sections: [InstitutionAccount.AccountType] = []
    var items: [InstitutionAccount.AccountType: [LinkAccountsItem]] = [:]
    var accountsToLink: [InstitutionAccount] {
        let flatItems = items.values.flatMap { $0 }
        let result = flatItems.filter { $0.isSelected }.map { $0.account }.sorted()

        return result
    }
    
    var subscriptions = Set<AnyCancellable>()
    var isDashboard = true
    var addedSavings: Bool?
    var isSettings: Bool = false
    var viewModel: LinkAccountsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let tableView = accounts {
            var inset = tableView.contentInset
            inset.top += 8.0
            tableView.contentInset = inset

            AccountCell.register(tableView: tableView)
        }

        view.addSubview(customNavBar)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])

        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
        
        viewModel?.$accountsLinked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accountsLinked in
                guard let accountsLinked, accountsLinked else { return }
                self?.accountsLinked()
            }
            .store(in: &subscriptions)
        
        viewModel?.$accountsExists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accountsExists in
                guard let accountsExists, accountsExists else { return }
                self?.updateSaveButton()
            }
            .store(in: &subscriptions)
    }
    
    private func save() {
        if saveButtonIsEnabled {
            guard let navigationController, let viewModel else { return }

            let linkInstitutionId = viewModel.institutionID
            let linkAccounts = accountsToLink

            BusyView.shared.show(navigationController: navigationController,
                                 title: NSLocalizedString("Updating Accounts", bundle: uiBundle, comment: "Updating Accounts"),
                                 subtitle: NSLocalizedString("Linking accounts...", bundle: uiBundle, comment: "Linking accounts..."),
                                 styles: AppStyles.shared,
                                 fullScreen: false) {
                Task {
                    await viewModel.linkAccounts(linkInstitutionID: linkInstitutionId, linkAccounts: linkAccounts)
                }
            }
        }
    }

    func updateSaveButton() {
        saveButtonIsEnabled = viewModel?.currentlyLinkedAccounts != accountsToLink
    }
    
    func accountsLinked() {
        BusyView.shared.hide()
        
        guard let navigationController else { return }
        
        if self.isDashboard {
            navigationController.popToRootViewController(animated: true)
        } else {
            Amplitude.instance().logEvent(OnboardingStep.linkBankAccounts.rawValue)
            
            let accountsCoordinator = AccountsCoordinator(presenter: navigationController, isBack: false, addedSavings: self.addedSavings, getStartedType: viewModel?.getStartedType, isSettings: self.isSettings)
            accountsCoordinator.start()
        }
    }
}

extension LinkAccountsViewController {
    func bind(availableAccounts: [InstitutionAccount], institutionID: String, isDashboard: Bool = true, addedSavings: Bool? = nil, isSettings: Bool = false, getStartedType: GetStartedViewType?) {
        loadViewIfNeeded()

        self.isDashboard = isDashboard
        apply(styles: AppStyles.shared)
        self.addedSavings = addedSavings
        self.isSettings = isSettings

        viewModel = LinkAccountsViewModel(institutionID: institutionID, isDashboard: isDashboard, getStartedType: getStartedType)
        
        setupListeners()
        
        if let tableView = accounts {
            dataSource = createDataSource(tableView: tableView)
            tableView.delegate = self
            tableView.dataSource = dataSource

            let sortedAccounts = availableAccounts.sorted().map { LinkAccountsItem(account: $0, isSelected: true) }
            items = Dictionary(grouping: sortedAccounts, by: { $0.account.accountType ?? .undefined })
            
            sections = items.keys.sorted()

            updateSnapshot(sections: sections, items: items, animated: false)
            updateSaveButton()
        }
    }

    func isLastInSection(indexPath: IndexPath) -> Bool {
        let isLastInSection = items[sections[indexPath.section]]?.count ?? 0 == indexPath.row + 1
        return isLastInSection
    }

    func sectionTitle(indexPath: IndexPath) -> String? {
        if indexPath.row != 0 {
            return nil
        }

        let sectionTitle = sections[indexPath.section].description

        return sectionTitle
    }

    func createDataSource(tableView: UITableView) -> DataSourceType {
        let result = UITableViewDiffableDataSource<InstitutionAccount.AccountType, LinkAccountsItem>(tableView: tableView) { [weak self] tableView, indexPath, account in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Account", for: indexPath)

            if let accountCell = cell as? AccountCell {
                let isLastInSection = self?.isLastInSection(indexPath: indexPath) ?? true
                let sectionTitle = self?.sectionTitle(indexPath: indexPath)

                accountCell.bind(account: account.account, isSelected: account.isSelected, styles: AppStyles.shared, isLastInSection: isLastInSection, sectionTitle: sectionTitle)
            }

            return cell
        }
        result.defaultRowAnimation = .none

        return result
    }

    func updateSnapshot(sections: [InstitutionAccount.AccountType],
                        items: [InstitutionAccount.AccountType: [LinkAccountsItem]],
                        animated: Bool) {
        var snapshot = SnapshotType()

        snapshot.appendSections(sections)
        items.forEach { section, accounts in
            snapshot.appendItems(accounts, toSection: section)
        }

        dataSource?.apply(snapshot, animatingDifferences: animated)
    }
}

extension LinkAccountsViewController: UITableViewDelegate {
    func item(indexPath: IndexPath) -> LinkAccountsItem? {
        return items[sections[indexPath.section]]?[indexPath.row]
    }

    func toggleSelected(indexPath: IndexPath, in items: [InstitutionAccount.AccountType: [LinkAccountsItem]]) -> [InstitutionAccount.AccountType: [LinkAccountsItem]] {
        let section = sections[indexPath.section]
        var items = items
        if var sectionItems = items[section] {
            sectionItems[indexPath.row].isSelected.toggle()
            items[section] = sectionItems
        }
        return items
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        items = toggleSelected(indexPath: indexPath, in: items)
        updateSnapshot(sections: sections, items: items, animated: true)
        updateSaveButton()
    }
}

extension LinkAccountsViewController: StoryboardInstantiable {
    static func instantiate() -> Self? {
        return instantiate(storyboard: "Accounts", identifier: "LinkAccounts")
    }
}
