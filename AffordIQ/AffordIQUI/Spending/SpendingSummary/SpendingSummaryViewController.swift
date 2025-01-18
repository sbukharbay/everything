//
//  SpendingSummaryViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 10/02/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine
import Amplitude

class SpendingSummaryViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private(set) lazy var backgroundImageView: BackgroundImageView = {
        let view = BackgroundImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var customNavBar: CustomNavigationBar = {
        let view = CustomNavigationBar(title: "Own Your Finances", rightButtonTitle: "Done") { [weak self] in
            self?.backButtonHanler()
        } rightButtonAction: { [weak self] in
            if let viewModel = self?.viewModel, viewModel.isOnboardingCategorisationDone && viewModel.isSettings {
                self?.backToSettings()
            } else {
                self?.showGetStarted()
            }
            self?.viewModel?.isOnboardingCategorisationDone = true
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = UIColor(hex: "#72F0F0")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var headerLabel: HeadingTitleLabel = {
        let view = HeadingTitleLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var titleStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 12
        view.alignment = .bottom
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var infoLabel: FieldLabelDark = {
        let view = FieldLabelDark()
        view.text = "Monthly Average"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var averageSpend: FieldLabelDark = {
        let view = FieldLabelDark()
        view.translatesAutoresizingMaskIntoConstraints = false
     
        return view
    }()

    private(set) lazy var averageTotalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .bottom
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var whiteBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var overlayLabel: FieldLabelSubheadlineLight = {
        let view = FieldLabelSubheadlineLight()
        view.text = "Monthly Average"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.register(SpendingSummaryTableViewCell.self)
        view.register(SpendingSummaryBreakdownTableViewCell.self)
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var emptyTableLabel: InfoLabel = {
        let view = InfoLabel()
        view.isHidden = true
        view.textAlignment = .center
        view.text = "You currently have no transactions"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override func viewDidLayoutSubviews() {
        setCustomNavBarConstraints()
    }

    var viewModel: SpendingSummaryViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    private var styles: AppStyles?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = viewModel?.isSettings ?? false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }

    func bind(getStartedType: GetStartedViewType? = nil,
              isSettings: Bool,
              isRecategorisationFlow: Bool,
              styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        viewModel = SpendingSummaryViewModel(getStartedType: getStartedType, isSettings: isSettings)

        setupSubviews()
        setupListeners()
        setInitialHeaderLabel()
        
        self.styles = styles
        apply(styles: styles)

        if isSettings {
            customNavBar.removeBlurView()
            customNavBar.setTitle(text: "")
        }

        viewModel?.isRecategorisationFlow = isRecategorisationFlow
        updateNavBar()

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
        
        viewModel?.updateTableSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willUpdate in
                guard let self, willUpdate else { return }
                self.updateTable()
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    self.showLoadingView(with: "Calculating Data")
                } else {
                    self.hideLoadingView()
                }
            }
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
        BusyView.shared.hide(success: true)
    }

    func updateTable() {
        if let viewModel, viewModel.averageCategorisedTransactions.isEmpty {
            emptyTableLabel.isHidden = false
            averageSpend.text = "£0.00"
        }
        tableView.reloadData()
    }

    func updateNavBar() {
        guard let viewModel else { return }
        
        if viewModel.isSettings {
            if viewModel.isRecategorisationFlow {
                customNavBar.hideLeftButton(hide: true)
                customNavBar.hideRightButton(hide: false)
            } else {
                customNavBar.hideLeftButton(hide: false)
                customNavBar.hideRightButton(hide: true)
            }
        } else {
            if viewModel.isSelected == true {
                customNavBar.hideLeftButton(hide: false)
                customNavBar.hideRightButton(hide: true)
            } else {
                customNavBar.hideLeftButton(hide: true)
                customNavBar.hideRightButton(hide: false)
            }
        }
    }

    func setInitialHeaderLabel() {
        if viewModel?.isSelected == false {
            iconImageView.image = UIImage(named: "spending", in: uiBundle, compatibleWith: nil)
            headerLabel.text = "Spending"
        }
    }

    func backButtonHanler() {
        if viewModel?.isSettings == true {
            if let isSelected = viewModel?.isSelected, isSelected {
                viewModel?.isSelected = false
                setInitialHeaderLabel()
                tableView.reloadData()
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            if let isSelected = viewModel?.isSelected, isSelected {
                viewModel?.isSelected = false
                setInitialHeaderLabel()
                updateNavBar()
                tableView.reloadData()
            }
        }
    }
    
    func showGetStarted() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                if viewModel.userSession.isOnboardingCompleted {
                    if let propertySearchResults = presenter.viewControllers.first(where: { $0 is DashboardSettingsViewController }) {
                        presenter.popToViewController(propertySearchResults, animated: true)
                    } else {
                        let coordinator = DashboardSettingsCoordinator(presenter: presenter)
                        coordinator.start()
                    }
                } else {
                    Amplitude.instance().logEvent(OnboardingStep.completeTransactionProcessing.rawValue)
                    
                    let coordinator = GetStartedCoordinator(presenter: presenter, type: viewModel.getStartedType == .savings ? .spending : viewModel.getStartedType)

                    coordinator.start()
                }
            })
        }
    }
    
    private func backToSettings() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                if viewModel.userSession.isOnboardingCompleted {
                    if let vc = presenter.viewControllers.last(where: { $0.isKind(of: DashboardSettingsViewController.self) }), 
                        let accountVC = vc as? DashboardSettingsViewController {
                        presenter.popToViewController(accountVC, animated: true)
                    }
                } else {
                    let coordinator = DashboardSettingsCoordinator(presenter: presenter)
                    coordinator.start()
                }
            })
        }
    }
}

extension SpendingSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel?.isSelected == false {
            return viewModel?.averageCategorisedTransactions[section].categorisedTransactionsSummaries.count ?? 0
        } else {
            return viewModel?.subCategoryData?.subCategorisedSpendingSummaries.count ?? 0
        }
    }
    
    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        if #available(iOS 14.0, *) {
            return 0
        }
        return 16
    }

    func numberOfSections(in _: UITableView) -> Int {
        if viewModel?.isSelected == false {
            return viewModel?.averageCategorisedTransactions.count ?? 0
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel?.isSelected == false {
            viewModel?.isSelected = true
            viewModel?.selectedRow = viewModel?.averageCategorisedTransactions[indexPath.section].categorisedTransactionsSummaries[indexPath.row]

            guard let parentId = viewModel?.selectedRow?.categoryId else { return }

            Task {
                await viewModel?.fetchSubCategory(for: parentId)
            }

            let icon: UIImage = .init(named: viewModel?.selectedRow?.icon ?? "", in: uiBundle, compatibleWith: nil) ?? UIImage(systemName: viewModel?.selectedRow?.icon ?? "")!
            iconImageView.image = icon

            headerLabel.text = viewModel?.selectedRow?.categoryName

            averageSpend.text = viewModel?.selectedRow?.averageValue.longDescription

            updateNavBar()

            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel else { return UITableViewCell() }

        if vm.isSelected == false {
            let cell = tableView.dequeueReusableCell(SpendingSummaryTableViewCell.self, for: indexPath)

            averageSpend.text = vm.spendingCategories?.monthlyAverage.longDescription

            cell.setupLayout(with: vm.averageCategorisedTransactions[indexPath.section].categorisedTransactionsSummaries[indexPath.row])
            if let styles {
                cell.style(styles: styles)
            }

            return cell
        } else {
            let breakdownCell = tableView.dequeueReusableCell(SpendingSummaryBreakdownTableViewCell.self, for: indexPath)

            breakdownCell.categoryLabel.text = vm.subCategoryData?.subCategorisedSpendingSummaries[indexPath.row].categoryName
            breakdownCell.averageSpend.text = vm.subCategoryData?.subCategorisedSpendingSummaries[indexPath.row].averageValue.longDescription
            if let styles {
                breakdownCell.style(styles: styles)
            }

            return breakdownCell
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 40
    }
}

extension SpendingSummaryViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
