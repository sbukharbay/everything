//
//  ChooseProviderViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class ChooseProviderViewController: FloatingButtonController, Stylable, TableDataProvider {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "background_opal_image", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let navBar = CustomNavigationBar(title: "Get Started") {
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .clear
        tableView.register(ProviderCell.self, forCellReuseIdentifier: "Provider")
        dataSource = createDataSource(tableView: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    private lazy var cardsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "linked_accounts", in: uiBundle, with: nil)
        return imageView
    }()

    private lazy var titleLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Link Bank Accounts"
        return label
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardsImageView, titleLabel])
        stackView.distribution = .fillProportionally
        stackView.setCustomSpacing(16, after: cardsImageView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private lazy var searchTitleLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Select Provider"
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = UISearchBar.Style.default
        bar.sizeToFit()
        bar.isTranslucent = true
        bar.delegate = self
        bar.backgroundImage = UIImage()
        bar.tintColor = .white
        bar.searchTextField.leftView?.tintColor = .white
        bar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.foregroundColor: UIColor.white])
        return bar
    }()

    var viewModel: ChooseProviderViewModel?
    var dataSource: DataSourceType?
    var currentProviders: [Provider] = []
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    typealias SectionType = String
    typealias ItemType = Provider

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearSelection()
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

    fileprivate func setupViews() {
        [backgroundImageView, blurEffectView, topStackView, searchTitleLabel, searchBar, tableView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),

            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            topStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            searchTitleLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 16),
            searchTitleLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),

            searchBar.topAnchor.constraint(equalTo: searchTitleLabel.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -8),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func bind(addedSavings: Bool? = nil, isSettings: Bool = false, getStartedType: GetStartedViewType?) {
        loadViewIfNeeded()

        viewModel = ChooseProviderViewModel(addedSavings: addedSavings, isSettings: isSettings, getStartedType: getStartedType)
        setupViews()
        setupListeners()
        apply(styles: AppStyles.shared)

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
        
        viewModel?.$presentProviders
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] params in
                guard let providers = params?.0, let animated = params?.1 else { return }
                self?.present(providers: providers, animated: animated)
            })
            .store(in: &subscriptions)
        
        viewModel?.$selectFrom
            .receive(on: DispatchQueue.main)
            .sink { [weak self] params in
                guard let accounts = params?.0, let id = params?.1 else { return }
                self?.selectFrom(availableAccounts: accounts, institutionId: id)
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showProgressView()
                } else {
                    self?.hideProgressView()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func showProgressView() {
        guard let presenter = navigationController else { return }
        BusyView.shared.show(navigationController: presenter,
                             title: NSLocalizedString("Preparing Providers", bundle: uiBundle, comment: "Preparing Providers"),
                             subtitle: NSLocalizedString("", bundle: uiBundle, comment: ""),
                             styles: AppStyles.shared,
                             fullScreen: false,
                             completion: {})
    }
    
    private func hideProgressView() {
        BusyView.shared.hide()
    }
    
    func createDataSource(tableView: UITableView) -> DataSourceType {
        let result = DataSourceType(tableView: tableView) { tableView, indexPath, provider in

            let cell = tableView.dequeueReusableCell(withIdentifier: "Provider", for: indexPath)

            if let providerCell = cell as? ProviderCell {
                providerCell.bind(provider: provider, styles: AppStyles.shared)
            }

            return cell
        }
        result.defaultRowAnimation = .automatic

        return result
    }

    func clearSelection() {
        tableView.indexPathsForVisibleRows?.forEach { [weak tableView] indexPath in

            tableView?.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension ChooseProviderViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        viewModel?.filter(with: searchText)
    }
}

extension ChooseProviderViewController: ErrorPresenter {
    func present(providers: [Provider], animated: Bool) {
        currentProviders = providers

        var snapshot = SnapshotType()

        snapshot.appendSections([Self.defaultSection])
        snapshot.appendItems(providers, toSection: Self.defaultSection)

        dataSource?.apply(snapshot, animatingDifferences: animated)
    }

    func selectFrom(availableAccounts: [InstitutionAccount], institutionId: String) {
        if let presenter = navigationController, let vm = viewModel {
            BusyView.shared.hide(success: true)

            let linkAccounts = LinkAccountsCoordinator(presenter: presenter, accounts: availableAccounts, institutionId: institutionId, isDashboard: false, addedSavings: vm.addedSavings, isSettings: vm.isSettings, getStartedType: vm.getStartedType)
            linkAccounts.start()
        }
    }
}

extension ChooseProviderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false

        if let presenter = navigationController {
            let provider = currentProviders[indexPath.row]

            let authenticationCoordinator = OpenBankingAuthorizationCoordinator(presenter: presenter, institutionId: provider.providerId, delegate: self, errorPresenter: self)
            authenticationCoordinator.start()
        }
    }
}

extension ChooseProviderViewController: OpenBankingAuthorizationDelegate {
    func didCancelAuthorization() {
        clearSelection()
        tableView.isUserInteractionEnabled = true
    }

    func didCompleteAuthorization(institutionId: String?, request: RMAuthoriseBank?) {
        tableView.isUserInteractionEnabled = true

        if let request = request, let institutionId = institutionId {
            Task {
                await viewModel?.setAuthorised(request: request, institutionID: institutionId)
            }
        }
    }
}

extension ChooseProviderViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
