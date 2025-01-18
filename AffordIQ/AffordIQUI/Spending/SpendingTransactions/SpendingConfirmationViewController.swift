//
//  SpendingConfirmationViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 13/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class SpendingConfirmationViewController: FloatingButtonController, Stylable, ErrorPresenter, ViewController {
    private(set) lazy var backgroundImageView: BackgroundImageView = .init(frame: view.frame)

    private(set) lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let view = CustomNavigationBar(title: "Own Your Finances") {
            self?.navigationController?.popViewController(animated: true)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var blurEffectViewTop: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var blurEffectViewBottom: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "spending", in: uiBundle, compatibleWith: nil)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var headerLabel: HeadingTitleLabel = {
        let view = HeadingTitleLabel()
        view.text = "Spending"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var titleStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .bottom
        view.spacing = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var categoryLabel: FieldLabelBoldDark = {
        let view = FieldLabelBoldDark()
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.adjustsFontForContentSizeCategory = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var yesButton: UIButton = {
        let view = UIButton()
        view.setTitle("Yes", for: .normal)
        view.backgroundColor = .clear
        view.setTitleColor(.cyan, for: .normal)
        view.addTarget(self, action: #selector(confirmOnButtonTap), for: .touchUpInside)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var pikeLabel: FieldLabelDark = {
        let view = FieldLabelDark()
        view.text = "  |  "
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var noButton: UIButton = {
        let view = UIButton()
        view.setTitle("No", for: .normal)
        view.backgroundColor = .clear
        view.setTitleColor(.cyan, for: .normal)
        view.addTarget(self, action: #selector(denyOnButtonTap), for: .touchUpInside)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var confirmButtonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .firstBaseline
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var informationLabel: BodyLabelDark = {
        let view = BodyLabelDark()
        view.text = "Is the below transaction for"
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var currentTransaction: SpendingConfirmationView = {
        let view = SpendingConfirmationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var tableViewBottom: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.register(SpendingConfirmationTableViewCell.self)
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var remainingSetsLabel: HeadingTitleLabelLight = {
        let view = HeadingTitleLabelLight()
        view.text = "Remaining Sets"
        view.isOpaque = true
        view.layer.opacity = 0.9
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var categoryStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .firstBaseline
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    var viewModel: SpendingConfirmationViewModel?
    private var styles: AppStyles?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    var blurTopEffectHeightConstraint: NSLayoutConstraint!

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

    func bind(
        transactions: [RecurringTransactionsModel],
        styles: AppStyles = AppStyles.shared,
        getStartedType: GetStartedViewType
    ) {
        loadViewIfNeeded()

        viewModel = SpendingConfirmationViewModel(transactions: transactions, getStartedType: getStartedType)
        showLoader()

        setupListeners()
        setupSubviews()
        
        self.styles = styles
        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    @objc private func confirmOnButtonTap() {
        viewModel?.confirmTransaction(save: false)
    }

    @objc private func denyOnButtonTap() {
        recategoriseTransaction()
    }
    
    private func showLoader() {
        guard let viewModel, let styles else { return }
        perform(action: { viewController in
            if let presenter = viewController.navigationController,
               viewModel.spendingStack.isEmpty,
               viewModel.currentSpending == nil {
                BusyView.shared.show(
                    navigationController: presenter,
                    title: NSLocalizedString("Preparing Transactions", bundle: uiBundle, comment: "Preparing Transactions"),
                    subtitle: NSLocalizedString("", bundle: uiBundle, comment: ""),
                    styles: styles,
                    fullScreen: false,
                    completion: {})
            }
        })
    }
    
    private func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let error else { return }
                self.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.updateTableSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willUpdate in
                guard let self, willUpdate else { return }
                self.updateView()
            }
            .store(in: &subscriptions)
        
        viewModel?.showCompletionSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willShow in
                guard let self, willShow else { return }
                self.showCompletion()
            }
            .store(in: &subscriptions)
        
        viewModel?.$isUserInteractionEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self else { return }
                self.set(interactionEnabled: isEnabled)
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
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
    }
    
    override func viewWillLayoutSubviews() {
        setCustomNavBarConstraints()
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
    
    func recategoriseTransaction() {
        if viewModel?.currentSpending != nil {
            perform(action: { viewController in
                if let presenter = viewController.navigationController {
                    presenter.dismiss(animated: true) {
                        let spendingCoordinator = SpendingCategoryCoordinator(presenter: presenter) { category in
                            Task {
                                self.viewModel?.currentCategory = category
                                await self.viewModel?.saveCategorisedTransactions()
                                self.viewModel?.confirmTransaction(save: true)
                            }
                        }
                        spendingCoordinator.start()
                    }
                }
            })
        }
    }
    
    private func updateView() {
        updateCurrentCell()
        tableViewBottom.reloadData()
    }
    
    private func updateCurrentCell() {
        guard let viewModel,
              let current = viewModel.currentSpending,
              !viewModel.isInitial
        else {
            currentTransaction.removeFromSuperview()
            return
        }
        deactivateBlurHeightConstraint()
        
        currentTransaction.merchantLabel.text = current.transactionDescription
        currentTransaction.paymentDateLabel.text = current.paymentPattern
        currentTransaction.costLabel.text = current.amount.longDescriptionAbsolute
        currentTransaction.setupSubviews()
        
        if let styles {
            currentTransaction.style(styles: styles)
        }
        
        categoryLabel.text = current.categoryName
    }
    
    func set(interactionEnabled: Bool) {
        asyncIfRequired { [weak self] in
            self?.view.isUserInteractionEnabled = interactionEnabled
        }
    }
    
    func showCompletion() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                presenter.dismiss(animated: true, completion: {
                    let isOnboardingCompleted = viewModel.userSession.isOnboardingCompleted
                    if isOnboardingCompleted && AccountsManager.shared.isOnboardingCategorisationDone {
                        let coordinator = SpendingSummaryCoordinator(presenter: presenter, getStartedType: nil, isSettings: isOnboardingCompleted, isRecategorisationFlow: true)
                        coordinator.start()
                    } else if AccountsManager.shared.isOnboardingCategorisationDone {
                        let coordinator = SpendingSummaryCoordinator(presenter: presenter, getStartedType: viewModel.getStartedType, isSettings: false, isRecategorisationFlow: true)
                        coordinator.start()
                    } else {
                        let coordinator = AlfiLoaderCoordinator(presenter: presenter, isSpending: true, getStartedType: viewModel.getStartedType)
                        coordinator.start()
                    }
                })
            }
        })
    }
}

extension SpendingConfirmationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.spendingStack.count ?? 3
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(SpendingConfirmationTableViewCell.self, for: indexPath)
        
        cell.content.merchantLabel.text = vm.spendingStack[indexPath.row].transactionDescription
        cell.content.paymentDateLabel.text = vm.spendingStack[indexPath.row].paymentPattern
        cell.content.costLabel.text = vm.spendingStack[indexPath.row].amount.longDescriptionAbsolute
        
        if let styles {
            cell.style(styles: styles)
        }

        return cell
    }
}

extension SpendingConfirmationViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
