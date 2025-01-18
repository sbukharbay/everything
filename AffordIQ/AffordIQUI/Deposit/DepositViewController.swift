//
//  DepositViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 19/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class DepositViewController: FloatingButtonController, Stylable, TableDataProvider {
    typealias SectionType = String
    typealias ItemType = DepositAccount

    @IBOutlet var currentDeposit: UILabel?
    @IBOutlet var externalCapital: UILabel?
    @IBOutlet var externalCapitalDescription: UILabel?
    @IBOutlet var overlay: TableOverlayView?
    @IBOutlet var targetHeight: NSLayoutConstraint?

    @IBOutlet var capitalBackground: UIView?

    @IBOutlet var addExternalCapital: UIButton?
    @IBOutlet var editExternalCapital: UIView?
    @IBOutlet var infoContainer: UIView?

    @IBOutlet var skipView: UIView?

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Own Your Finances") { [weak self] in
            self?.back()
        }
        return navBar
    }()

    private lazy var addAccountsButton: DarkBlueButton = {
        let button = DarkBlueButton()
        button.setTitle("Link Accounts", for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(navigateToLinkedAccounts), for: .touchUpInside)
        return button
    }()

    private let linkAccountsInformationLabel: InfoLabel = {
        let label = InfoLabel()
        label.text = "You currently don't have any savings accounts linked. Tap the button below to link any you may have."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    var viewModel: DepositViewModel?
    var dataSource: DataSourceType?
    var items: [DepositAccount] = []
    private var styles: AppStyles?
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        [customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func bind(targetHeight: CGFloat?,
              styles: AppStyles = AppStyles.shared,
              showNextButton: Bool = false, isSettings: Bool) {
        loadViewIfNeeded()

        if let overlay = overlay {
            overlay.heading = nil
            overlay.title = nil

            if let tableView = overlay.tableView {
                tableView.separatorStyle = .none
                dataSource = createDataSource(tableView: tableView)
            }
        }

        if showNextButton {
            customNavBar.addRightButton(title: "Next") { [weak self] in
                Task {
                    await self?.viewModel?.confirm()
                }
            }
        }

        viewModel = DepositViewModel(view: self)

        if let targetHeight = targetHeight {
            self.targetHeight?.constant = targetHeight
        }

        if isSettings {
            customNavBar.removeBlurView()
            customNavBar.setTitle(text: "")
        }

        self.styles = styles
        apply(styles: styles)
        
        setupListeners()

        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    func reload() {
        viewModel?.reload()
    }
    
    func setupListeners() {
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showBusyView(text: NSLocalizedString("Calculating Data", bundle: uiBundle, comment: "Calculating Data"))
                } else {
                    BusyView.shared.hide(success: true)
                }
            }
            .store(in: &subscriptions)
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

    func noSavingsSetup() {
        [linkAccountsInformationLabel, addAccountsButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            linkAccountsInformationLabel.centerXAnchor.constraint(equalTo: overlay!.centerXAnchor),
            linkAccountsInformationLabel.centerYAnchor.constraint(equalTo: overlay!.centerYAnchor),
            linkAccountsInformationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            linkAccountsInformationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            addAccountsButton.topAnchor.constraint(equalTo: linkAccountsInformationLabel.bottomAnchor, constant: 28),
            addAccountsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            addAccountsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28)
        ])
    }

    func createDataSource(tableView: UITableView) -> DataSourceType {
        DepositAccountCell.register(tableView: tableView)
        TotalSavingsHeaderView.register(tableView: tableView)

        tableView.delegate = self

        let newDataSource = DataSourceType(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, account in
                let cell = tableView.dequeueReusableCell(withIdentifier: DepositAccountCell.reuseIdentifier, for: indexPath)
                
                if let styles = self?.styles, let depositAccountCell = cell as? DepositAccountCell {
                    depositAccountCell.bind(account: account, styles: styles)
                    depositAccountCell.layoutIfNeeded()
                }
                
                return cell
            }
        )
        
        return newDataSource
    }

    func updateSnapshot(animated: Bool) {
        var snapshot = SnapshotType()

        snapshot.appendSections([Self.defaultSection])
        snapshot.appendItems(items, toSection: Self.defaultSection)

        dataSource?.apply(snapshot, animatingDifferences: animated)
    }

    func presentNext() {
        if let presenter = navigationController {
            let getStartedCoordinator = GetStartedCoordinator(presenter: presenter, type: .savings)
            getStartedCoordinator.start()
        }
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc func navigateToLinkedAccounts(_: Any?) {
        if let presenter = navigationController {
            let accountsCoordinator = AccountsCoordinator(presenter: presenter, isBack: true, addedSavings: true, getStartedType: GetStartedViewType.linkedBankAccounts)
            accountsCoordinator.start()
        }
    }

    @IBAction func updateOutsideCapital(_: Any?) {
        if let presenter = navigationController {
            let coordinator = ExternalCapitalCoordinator(presenter: presenter, targetHeight: targetHeight?.constant, externalCapital: viewModel?.externalCapital)
            coordinator.start()
        }
    }

    @IBAction func deleteOutsideCapital(_: Any?) {
        Task {
            await viewModel?.deleteOutsideCapital()
        }
    }

    @IBAction func skipButtonHandle(_: Any) {
        Task {
            await viewModel?.confirm()
        }
    }
    
    func showBusyView(text: String? = nil) {
        if let navigationController = navigationController, let styles {
            var title = ""
            var subtitle = ""
            
            if let text {
                title = text
            } else {
                title = NSLocalizedString("Updating...", bundle: uiBundle, comment: "Updating...")
                subtitle = NSLocalizedString("Updating your accounts...", bundle: uiBundle, comment: "Updating your accounts...")
            }

            BusyView.shared.show(navigationController: navigationController, title: title, subtitle: subtitle, styles: styles, fullScreen: false)
        }
    }
}

extension DepositViewController: StoryboardInstantiable {
    static func instantiate() -> Self? {
        return instantiate(storyboard: "Affordability", identifier: "Deposit")
    }
}

extension DepositViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = viewModel {
            var depositAccount = items[indexPath.row]
            depositAccount.isSelected.toggle()
            items[indexPath.row] = depositAccount
            
            let contributesToDeposit = items
                .filter { $0.isSelected }
                .map { $0.account.accountId }

            let doesNotContributeToDeposit = items
                .filter { !$0.isSelected }
                .map { $0.account.accountId }
            
            showBusyView()
            
            Task {
                await viewModel.updateAccounts(contributesToDeposit: contributesToDeposit, doesNotContributeToDeposit: doesNotContributeToDeposit) { ok in
                    self.present(accounts: self.items, animated: false)
                    
                    var savings = MonetaryAmount(amount: 0)
                    
                    self.items.forEach { deposit in
                        if deposit.isSelected {
                            savings += deposit.account.balance?.currentBalance ?? MonetaryAmount(amount: 0)
                        }
                    }
                    
                    let header = self.overlay?.tableView?.headerView(forSection: 0) as? TotalSavingsHeaderView
                    header?.setSavings(savings)
                    
                    BusyView.shared.hide(success: ok)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TotalSavingsHeaderView.reuseIdentifier)

        if let header = view as? TotalSavingsHeaderView {
            header.bind()
        }
        return view
    }
}

extension DepositViewController: DepositView {
    func set(externalCapitalAmount: MonetaryAmount?, externalCapitalDescription: String) {
        if let externalCapitalAmount = externalCapitalAmount {
            editExternalCapital?.isHidden = false
            infoContainer?.isHidden = true
            addExternalCapital?.isHidden = true

            externalCapital?.text = externalCapitalAmount.shortDescription
            self.externalCapitalDescription?.text = externalCapitalDescription + "\nTotal: " + externalCapitalAmount.shortDescription

            capitalBackground?.layer.shadowColor = UIColor.gray.cgColor
            capitalBackground?.layer.shadowOpacity = 0.7
            capitalBackground?.layer.shadowOffset = CGSize.zero
        } else {
            editExternalCapital?.isHidden = true
            infoContainer?.isHidden = false
            addExternalCapital?.isHidden = false

            infoContainer?.layer.shadowColor = UIColor.gray.cgColor
            infoContainer?.layer.shadowOpacity = 0.7
            infoContainer?.layer.shadowOffset = CGSize.zero
            capitalBackground?.layer.shadowOpacity = 0
        }
    }

    func set(savings: NSAttributedString?) {
        overlay?.heading = savings
    }

    func set(currentDeposit: String?) {
        self.currentDeposit?.text = currentDeposit
    }

    func skip(hide: Bool) {
        skipView?.isHidden = hide
    }

    func present(accounts: [DepositAccount], animated: Bool) {
        items = accounts
        updateSnapshot(animated: animated)
    }

    func addAccounts(hide: Bool) {
        noSavingsSetup()

        addAccountsButton.isHidden = hide
        linkAccountsInformationLabel.isHidden = hide
    }
}
