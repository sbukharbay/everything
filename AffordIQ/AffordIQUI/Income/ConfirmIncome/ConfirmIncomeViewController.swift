//
//  ConfirmIncomeViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 15/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Amplitude
import Combine

class ConfirmIncomeViewController: FloatingButtonController, Stylable, ViewController, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let navBar = CustomNavigationBar(title: "Own Your Finances", rightButtonTitle: "Done") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: {
            self?.doneButtonHandle()
        }
        return navBar
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "income", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private let titleLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Income"
        return label
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.setCustomSpacing(12, after: iconImageView)
        stackView.alignment = .bottom
        return stackView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.register(ConfirmIncomeTableViewCell.self, forCellReuseIdentifier: ConfirmIncomeTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private var viewModel: ConfirmIncomeViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var styles: AppStyles?
    private var subscriptions = Set<AnyCancellable>()

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

    func bind(incomeData: IncomeStatusDataModel?,
              getStartedType: GetStartedViewType?,
              isBack: Bool,
              isSettings: Bool,
              styles: AppStyles = AppStyles.shared
    ) {
        loadViewIfNeeded()

        viewModel = ConfirmIncomeViewModel(
            incomeData: incomeData,
            getStartedType: getStartedType,
            isBack: isBack,
            isSettings: isSettings
        )

        setupViews()
        setupListeners()
        apply(styles: styles)
        self.styles = styles

        if isSettings {
            customNavBar.removeBlurView()
            customNavBar.setTitle(text: "")
        }

        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.present(error: error)
            }
            .store(in: &subscriptions)
        
        // Listen for willUpdate
        viewModel?.willUpdateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willUpdate in
                guard let self, willUpdate else { return }
                self.update()
            }
            .store(in: &subscriptions)
        
        // Listen for didOperationComplete
        viewModel?.didOperationCompleteSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] didComplete in
                guard let self, didComplete else { return }
                self.operationComplete()
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    self.showLoadingView(with: "Preparing Data")
                } else {
                    self.hideLoadingView()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$isDone
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isDone in
                guard let self else { return }
                if isDone {
                    self.showLoadingView(with: "Loading...")
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

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    func setupViews() {
        [backgroundImageView, blurEffectView, titleStackView, tableView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -170),

            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),

            titleStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            titleStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor)
        ])
    }

    func doneButtonHandle() {
        Task { await viewModel?.setConfirmIncome() }
    }

    func update() {
        tableView.reloadData()
    }
}

extension ConfirmIncomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel?.rowTitle.count ?? 0
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            setEmploymentStatus()
        } else if indexPath.row == 1 {
            setIncome()
        } else {
            setMonthlyIncome()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ConfirmIncomeTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ConfirmIncomeTableViewCell,
              let vm = viewModel,
              let styles else { return UITableViewCell() }

        cell.subTitle.text = vm.rowTitle[indexPath.row].subTitle
        cell.userValueLabel.text = vm.rowTitle[indexPath.row].value
        cell.apply(styles: styles)
        cell.groupCell(row: indexPath.row)

        return cell
    }
}

extension ConfirmIncomeViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}

// MARK: - Navigation
extension ConfirmIncomeViewController {
    func setIncome() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                presenter.dismiss(animated: true, completion: {
                    switch viewModel.incomeData?.employmentStatus {
                    case .selfEmployed:
                        let coordinator = SelfEmployedTypeCoordinator(
                            presenter: presenter,
                            incomeData: viewModel.incomeData,
                            getStartedType: viewModel.getStartedType,
                            isSettings: viewModel.isSettings)
                        coordinator.start()
                    default:
                        let coordinator = SetSalaryCoordinator(
                            presenter: presenter,
                            incomeData: viewModel.incomeData,
                            getStartedType: viewModel.getStartedType,
                            isSettings: viewModel.isSettings)
                        coordinator.start()
                    }
                })
            }
        })
    }
    
    func setMonthlyIncome() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                presenter.dismiss(animated: true, completion: {
                    switch viewModel.incomeData?.employmentStatus {
                    case .selfEmployed:
                        let coordinator = SelfEmployedProfitCoordinator(
                            presenter: presenter,
                            incomeData: viewModel.incomeData,
                            getStartedType: viewModel.getStartedType,
                            isSettings: viewModel.isSettings)
                        coordinator.start()
                    default:
                        let coordinator = SetSalaryCoordinator(
                            presenter: presenter,
                            incomeData: viewModel.incomeData,
                            getStartedType: viewModel.getStartedType,
                            isSettings: viewModel.isSettings)
                        coordinator.start()
                    }
                })
            }
        })
    }
    
    func setEmploymentStatus() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                let employmentStatusCoordinator = EmploymentStatusCoordinator(
                    presenter: presenter,
                    incomeData: viewModel.incomeData,
                    getStartedType: viewModel.getStartedType,
                    isSettings: viewModel.isSettings
                )
                employmentStatusCoordinator.start()
            }
        })
    }
    
    func operationComplete() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                presenter.dismiss(animated: true, completion: {
                    if viewModel.isSettings {
                        if let propertySearchResults = presenter.viewControllers.first(where: { $0 is DashboardSettingsViewController }) {
                            presenter.popToViewController(propertySearchResults, animated: true)
                        } else {
                            let coordinator = DashboardSettingsCoordinator(presenter: presenter)
                            coordinator.start()
                        }
                    } else {
                        Amplitude.instance().logEvent(OnboardingStep.addIncomeInfo.rawValue)
                        
                        let getStartedCoordinator = GetStartedCoordinator(presenter: presenter, type: viewModel.getStartedType)
                        getStartedCoordinator.start()
                    }
                })
            }
        })
    }
}
