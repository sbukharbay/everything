//
//  AccountDetailsViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

protocol AccountDeletionDelegate: AnyObject {
    func deleteAccount(with accountID: String)
}

class AccountDetailsViewController: FloatingButtonController, Stylable, TableDataProvider, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var accountTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        AccountCell.register(tableView: tableView)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var overlayView: TableOverlayView = {
        let view = TableOverlayView(frame: .zero)
        view.tabVisible = false
        view.heading = nil
        view.title = nil
        return view
    }()

    private lazy var whiteBackgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Account Details") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()

    typealias SectionType = String
    typealias ItemType = AccountDetailsViewContent

    var viewModel: AccountDetailsViewModel?
    var dataSource: DataSourceType?
    var pendingSnapshot: SnapshotType?
    lazy var styles = AppStyles.shared
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    weak var delegate: AccountDeletionDelegate?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        if let pendingSnapshot = pendingSnapshot {
            dataSource?.apply(pendingSnapshot, animatingDifferences: false)
        }
        pendingSnapshot = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

    func bind(account: InstitutionAccount, delegate: AccountDeletionDelegate?, institutionAccounts: [InstitutionAccount], isLast: Bool) {
        loadViewIfNeeded()

        if let content = overlayView.tableView {
            content.separatorStyle = .none
            content.isScrollEnabled = false
            dataSource = createDataSource(tableView: content)
            content.dataSource = dataSource
        }
        
        self.delegate = delegate
        viewModel = AccountDetailsViewModel(view: self, account: account, institutionAccounts: institutionAccounts, isLast: isLast)
        setupViews()
        setupListeners()

        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
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
    }

    func setupViews() {
        [backgroundImageView, accountTableView, whiteBackgroundView, overlayView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            accountTableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 24),
            accountTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            accountTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            accountTableView.heightAnchor.constraint(equalToConstant: 150),

            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            overlayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),

            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            whiteBackgroundView.topAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -8)
        ])
    }

    func createDataSource(tableView: UITableView) -> DataSourceType {
        AccountAccessCell.register(tableView: tableView)
        AccountConsentCell.register(tableView: tableView)
        AccountConsentHeaderCell.register(tableView: tableView)
        AccountDisconnectionCell.register(tableView: tableView)
        tableView.register(AccountReconsentCell.self)
        
        let newDataSource = DataSourceType(tableView: tableView) { [weak self] tableView, indexPath, item -> UITableViewCell? in
            guard let self else { return UITableViewCell() }
            switch item {
            case let .expiry(content):
                let cell = tableView.dequeueReusableCell(AccountAccessCell.self, for: indexPath)
                cell.bind(content: content)
                return cell
            case .reconsent:
                let cell = tableView.dequeueReusableCell(AccountReconsentCell.self, for: indexPath)
                cell.delegate = self
                cell.configure()
                
                return cell
            case .disconnect:
                let cell = tableView.dequeueReusableCell(AccountDisconnectionCell.self, for: indexPath)
                cell.bind(delegate: self)
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        return newDataSource
    }
    
    func reload() {
        Task {
            await viewModel?.updateAccount()
        }
    }
}

extension AccountDetailsViewController: AccountDetailsView {
    func present(content: [[AccountDetailsViewContent]]) {
        var snapshot = SnapshotType()
        var section = 0

        content.forEach { sectionContent in
            snapshot.appendSections([String(section)])
            snapshot.appendItems(sectionContent)
            section += 1
        }

        if view.window == nil {
            pendingSnapshot = snapshot
        } else {
            if let dataSource = dataSource {
                dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
}

extension AccountDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.reuseIdentifier, for: indexPath) as? AccountCell, let vm = viewModel else { return UITableViewCell() }
        cell.bind(account: vm.account, styles: styles)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}

extension AccountDetailsViewController: StoryboardInstantiable {
    static func instantiate() -> Self? {
        return instantiate(storyboard: "Accounts", identifier: "AccountDetails")
    }
}

extension AccountDetailsViewController: AccountDisconnectionDelegate {
    func disconnect(all: Bool) {
        if let navigationController = navigationController,
           let viewModel = viewModel {
            view.isUserInteractionEnabled = false
            BusyView.shared.show(navigationController: navigationController,
                                 title: NSLocalizedString("Updating Accounts", bundle: uiBundle, comment: "Updating Accounts"),
                                 subtitle: NSLocalizedString("Unlinking accounts...", bundle: uiBundle, comment: "Unlinking accounts..."),
                                 styles: styles,
                                 fullScreen: false) {
                viewModel.disconnect(all: all, completion: { [weak self] ok in
                    asyncIfRequired {
                        BusyView.shared.hide()

                        if !ok {
                            self?.view.isUserInteractionEnabled = true
                        } else {
                            self?.delegate?.deleteAccount(with: viewModel.account.accountId)
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
    }

    func disconnectSingleAccount(_: UIAlertAction) {
        disconnect(all: false)
    }

    func disconnect() {
        if let account = viewModel?.account {
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let preferredStyle: UIAlertController.Style = isPad ? .alert : .actionSheet

            let messageFormat = NSLocalizedString("Unlink this account for %1$@?", bundle: uiBundle, comment: "Unlink this account for %1$@?")
            let message = String.localizedStringWithFormat(messageFormat, account.providerDisplayName)
            let alertController = UIAlertController(title: message, message: nil, preferredStyle: preferredStyle)

            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("Unlink", bundle: uiBundle, comment: "Unlink"),
                              style: .destructive,
                              handler: disconnectSingleAccount(_:)))
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("Cancel", bundle: uiKitBundle, comment: "Cancel"),
                              style: .cancel))

            present(alertController, animated: true)
        }
    }
}

extension AccountDetailsViewController: AccountReconsentCellDelegate {
    func onReconsentButtonClick(_ cell: UITableViewCell) {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = ReconsentProcessingCoordinator(presenter: presenter, providers: ReconsentRequestModel(providers: [ReconsentProvider(provider: viewModel.account.institutionId, renew: true)]), preReconsentType: .accountDetails)
                coordinator.start()
            })
        }
    }
}
