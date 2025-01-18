//
//  PropertyResultsViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 21.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import Amplitude
import Combine
import UIKit
import AffordIQAuth0

class PropertyResultsViewController: FloatingButtonController, Stylable, TableDataProvider, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Set a Goal") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navBar.addFiltersSection { [weak self] in
            self?.filterHandle()
        } whenAction: { [weak self] in
            self?.whenHandle()
        }

        return navBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.separatorStyle = .none
        return tableView
    }()

    private let backgroundBlueView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.backgroundColor = UIColor(hex: "0F0728")
        return view
    }()

    private let selectPropertyLabel: StandardLabel = {
        let label = StandardLabel()
        label.text = "Select a Property"
        label.textColor = UIColor(hex: "#72F0F0")
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        return label
    }()

    typealias SectionType = String
    typealias ItemType = PropertySearchResult

    private var viewModel: PropertySearchViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    var subscriptions: Set<AnyCancellable> = []
    var dataSource: DataSourceType?
    var pendingSnapshot: SnapshotType?
    var chosenParameters: ChosenPropertyParameters!
    var isDashboard = false

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 100 + view.safeAreaInsets.top),

            backgroundBlueView.heightAnchor.constraint(equalToConstant: view.safeAreaInsets.bottom + 60)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        if let pendingSnapshot = pendingSnapshot {
            dataSource?.apply(pendingSnapshot, animatingDifferences: false)
        }
        pendingSnapshot = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }

    func bind(search: ChosenPropertyParameters, mortgageLimits: MortgageLimits?, months: Int, isDashboard: Bool) {
        loadViewIfNeeded()

        self.isDashboard = isDashboard
        chosenParameters = search
        dataSource = createDataSource(tableView: tableView)
        
        let newViewModel = PropertySearchViewModel(search: search.suggestion, parameters: search, mortgageLimits: mortgageLimits, months: months)
        viewModel = newViewModel

        setupViews()
        setupListeners()
        apply(styles: AppStyles.shared)
        
        selectPropertyLabel.isHidden = newViewModel.userSession.isOnboardingCompleted
        backgroundBlueView.isHidden = newViewModel.userSession.isOnboardingCompleted
        
        bringFeedbackButton(String(describing: type(of: self)))
    }

    func setupViews() {
        [backgroundImageView, tableView, backgroundBlueView, selectPropertyLabel, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: backgroundBlueView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backgroundBlueView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundBlueView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundBlueView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundBlueView.heightAnchor.constraint(equalToConstant: 64),
            
            selectPropertyLabel.centerXAnchor.constraint(equalTo: backgroundBlueView.centerXAnchor),
            selectPropertyLabel.centerYAnchor.constraint(equalTo: backgroundBlueView.centerYAnchor, constant: -8)
        ])
    }

    private func setupListeners() {
        viewModel?.$zooplaErrorAlert
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isError in
                guard isError else { return }
                self?.zooplaErrorAlert()
            })
            .store(in: &subscriptions)
        
        viewModel?.$showNext
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] showNext in
                guard let showNext, showNext else { return }
                self?.showNext()
            })
            .store(in: &subscriptions)
        
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let error else { return }
                self.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    self.showLoadingView(with: "Loading...")
                } else {
                    self.hideLoadingView()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.searchResults
            .sink(receiveCompletion: noCompletion(_:),
                  receiveValue: { [weak self] results in
                self?.present(results: results)
            })
            .store(in: &subscriptions)
    }
    
    private func showLoadingView(with message: String) {
        guard let navigationController else { return }
        BusyView.shared.show(
            navigationController: navigationController,
            title: NSLocalizedString(message, bundle: uiBundle, comment: message),
            fullScreen: false
        )
    }
    
    private func hideLoadingView() {
        BusyView.shared.hide()
    }

    func filterHandle() {
        if let viewModel = viewModel, let presenter = navigationController {
            let coordinator = PropertyParametersCoordinator(presenter: presenter, homeValue: viewModel.searchParameters.homeValue, parameters: chosenParameters, months: viewModel.months)
            coordinator.start()
        }
    }

    func whenHandle() {
        if let viewModel = viewModel, let presenter = navigationController {
            let coordinator = AffordabilityMainCoordinator(presenter: presenter, type: .filter(search: viewModel.searchParameters, mortgageLimits: viewModel.mortgageLimits), isDashboard: isDashboard)
            coordinator.start()
        }
    }

    func zooplaErrorAlert() {
        var customAlertView: ConfirmationAlertView!
        customAlertView = ConfirmationAlertView(style: AppStyles.shared, title: "Sorry, this service is currently unavailable, please try again in 1 hour", buttonTitle: "Ok", buttonAction: { [weak self] in
            customAlertView.removeFromSuperview()
            self?.navigationController?.popViewController(animated: true)
        })

        guard let alertView = customAlertView else { return }

        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    func createDataSource(tableView: UITableView) -> DataSourceType {
        PropertyCell.register(tableView: tableView)
        PropertyLoadingCell.register(tableView: tableView)
        PropertyNoResultsCell.register(tableView: tableView)

        tableView.delegate = self

        let newDataSource = DataSourceType(tableView: tableView) { [weak self] _, indexPath, searchResult -> UITableViewCell? in

            switch searchResult {
            case .placeholder:
                let cell = tableView.dequeueReusableCell(withIdentifier: PropertyLoadingCell.reuseIdentifier, for: indexPath)

                if let propertyCell = cell as? PropertyLoadingCell {
                    propertyCell.bind(styles: AppStyles.shared)
                }

                self?.viewModel?.nextPage()

                return cell

            case .result:
                let cell = tableView.dequeueReusableCell(withIdentifier: PropertyCell.reuseIdentifier, for: indexPath)

                if let propertyCell = cell as? PropertyCell {
                    propertyCell.bind(mortgageLimits: self?.viewModel?.mortgageLimits, result: searchResult)
                }

                return cell

            case .noResults:
                let cell = tableView.dequeueReusableCell(withIdentifier: PropertyNoResultsCell.reuseIdentifier, for: indexPath)

                if let propertyCell = cell as? PropertyNoResultsCell {
                    propertyCell.bind(delegate: nil, styles: AppStyles.shared)
                }

                return cell
            }
        }

        newDataSource.defaultRowAnimation = .fade

        return newDataSource
    }

    func present(results: [PropertySearchResult]) {
        var snapshot = SnapshotType()
        snapshot.appendSections([Self.defaultSection])
        snapshot.appendItems(results, toSection: Self.defaultSection)

        if view.window == nil {
            pendingSnapshot = snapshot
        } else {
            pendingSnapshot = nil
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }

    func perform(for indexPath: IndexPath, action: (Listing) -> Void) {
        if let result = dataSource?.itemIdentifier(for: indexPath) {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)

            switch result {
            case let .result(listing):
                action(listing)

            default:
                break
            }
        }
    }

    func openListing(listing: Listing) {
        if let navigationController = navigationController {
            let propertyDetailsCoordinator = PropertyDetailsCoordinator(presenter: navigationController, listing: listing)
            propertyDetailsCoordinator.start()
        }
    }

    func setPropertyGoal(listing: Listing) {
        Task {
            await viewModel?.setPropertyGoal(listing: listing)
        }
    }

    private func showNext() {
        if let navigationController = navigationController {
            if isDashboard {
                navigationController.viewControllers.forEach { vc in
                    if vc.isKind(of: SetAGoalCheckPointViewController.self) {
                        navigationController.popToViewController(vc, animated: true)
                        return
                    }
                }
            } else {
                Amplitude.instance().logEvent(OnboardingStep.setPropertyGoal.rawValue)

                let coordinator = SetAGoalCheckPointCoordinator(presenter: navigationController, type: .property)
                coordinator.start()
            }
        }
    }
}

extension PropertyResultsViewController: UITableViewDelegate {
    func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        perform(for: indexPath) { listing in
            
            let message = NSLocalizedString(
                "The property details will be opened on Zoopla.\nBlackArrow Group is not responsible for the content of third-party websites.",
                bundle: uiBundle,
                comment: "The property details will be opened on Zoopla.\nBlackArrow Group is not responsible for the content of third-party websites.")
            
            let preferredStyle: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
            let alertController = UIAlertController(title: nil,
                                                    message: message,
                                                    preferredStyle: preferredStyle)

            alertController.addAction(UIAlertAction(title: NSLocalizedString("View Details", bundle: uiBundle, comment: "View Details"),
                                                    style: .default) { [weak self] _ in
                
                self?.openListing(listing: listing)
            })
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: uiKitBundle, comment: "Cancel"),
                                                    style: .cancel))

            navigationController?.present(alertController, animated: true, completion: nil)
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preferredStyle: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        perform(for: indexPath) { listing in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)
            
            alertController.addAction(
                UIAlertAction(
                    title: NSLocalizedString(
                        "Set Property Goal",
                        bundle: uiBundle,
                        comment: "Set Property Goal"
                    ),
                    style: .default
                ) { [weak self] _ in
                    self?.setPropertyGoal(listing: listing)
                }
            )
            
            alertController.addAction(
                UIAlertAction(
                    title: NSLocalizedString(
                        "Cancel",
                        bundle: uiKitBundle,
                        comment: "Cancel"
                    ),
                    style: .cancel
                )
            )
            
            navigationController?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension PropertyResultsViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
