//
//  SetAGoalCheckPointViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 01/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class SetAGoalCheckPointViewController: FloatingButtonController, Stylable, ViewController, ErrorPresenter {
    private(set) lazy var backgroundImageView: BackgroundImageView = .init(frame: view.frame)

    private(set) lazy var customNavBar: CustomNavigationBar = {
        let view = CustomNavigationBar(title: "Set a Goal", rightButtonTitle: "Property") { [weak self] in
            self?.handleBack()
        } rightButtonAction: { [weak self] in
            self?.handleNext()
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

    private(set) lazy var headerLabel: HeadingTitleLabel = {
        let view = HeadingTitleLabel()
        view.text = "Set a Goal"
        view.textAlignment = .center
        view.baselineAdjustment = .alignCenters
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var titleIconImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "goal", in: uiBundle, compatibleWith: nil)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var titleStackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.delegate = self
        view.dataSource = self
        view.register(GetStartedTableViewCell.self)
        view.register(SetAGoalCheckPointTableViewFooter.self)
        view.register(SetAGoalCheckPointTableViewHeader.self)
        view.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .clear
        view.separatorColor = .clear
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    var viewModel: SetAGoalCheckPointViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    private var styles: AppStyles?

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

    func rightbuttonName() {
        switch viewModel?.viewType {
        case .property:
            customNavBar.renameRightButtonTitle(text: "Deposit")
        case .deposit:
            customNavBar.renameRightButtonTitle(text: "Budget")
        case .savingGoal:
            customNavBar.renameRightButtonTitle(text: "Property")
        case .budget:
            customNavBar.renameRightButtonTitle(text: "Finish")
        default:
            customNavBar.renameLeftButton(setTitle: "Back")
            customNavBar.hideRightButton(hide: true)
            customNavBar.setTitle(text: "Edit Goal")
        }
    }

    func bind(goalType: SetAGoalCheckPointViewType,
              getStartedType: GetStartedViewType? = nil,
              isBackAvailable: Bool = true,
              styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()
        
        setupSubviews()

        if !isBackAvailable {
            customNavBar.hideLeftButton(hide: true)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        titleStackView.isHidden = goalType != .savingGoal

        viewModel = SetAGoalCheckPointViewModel(
            viewType: goalType,
            getStartedType: getStartedType,
            isBackAvailable: isBackAvailable
        )

        setupListeners()
        rightbuttonName()
        
        self.styles = styles
        apply(styles: styles)
        
        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    override func viewWillLayoutSubviews() {
        setCustomNavBarConstraints()
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
        
        viewModel?.$isLoadingData
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let vm = self?.viewModel, vm.isBackAvailable, let navigationController = self?.navigationController else { return }
                if isLoading {
                    BusyView.shared.show(
                        navigationController: navigationController,
                        title: NSLocalizedString("Calculating Data", bundle: uiBundle, comment: "Calculating Data"),
                        fullScreen: false
                    )
                } else {
                    BusyView.shared.hide(success: true)
                }
            }
            .store(in: &subscriptions)
    }

    func handleNext() {
        switch viewModel?.viewType {
        case .savingGoal:
            propertyGoal()
        case .property:
            depositGoal()
        case .deposit:
            savingBudget()
        default:
            completeGoals()
        }
    }
    
    func handleBack() {
        if let navigationController, let vc = navigationController.viewControllers.last(where: { $0.isKind(of: GoalsViewController.self) }), let goalsVC = vc as? GoalsViewController {
            goalsVC.resume()
            navigationController.popToViewController(goalsVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func savingsGoal() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                let savingsGoalCoordinator = SetSavingsGoalCoordinator(presenter: presenter, isDashboard: viewModel.viewType == .dashboard)
                savingsGoalCoordinator.start()
            }
        })
    }
    
    func propertyGoal() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                let coordinator = AffordabilityMainCoordinator(presenter: presenter, type: viewModel.viewType == .dashboard ? .dashboard : .setGoal, isDashboard: viewModel.viewType == .dashboard)
                coordinator.start()
            }
        })
    }
    
    func depositGoal() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                let savingsGoalCoordinator = SetDepositGoalCoordinator(presenter: presenter, isDashboard: viewModel.viewType == .dashboard)
                savingsGoalCoordinator.start()
            }
        })
    }
    
    func savingBudget() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                presenter.dismiss(animated: true) {
                    let savingBudgetCoordinator = SavingBudgetCoordinator(presenter: presenter, isDashboard: viewModel.viewType == .dashboard)
                    savingBudgetCoordinator.start()
                }
            }
        })
    }
    
    func completeGoals() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                presenter.dismiss(animated: true, completion: {
                    let getStartedCoordinator = GetStartedCoordinator(presenter: presenter, type: viewModel.getStartedType)
                    getStartedCoordinator.start()
                })
            }
        })
    }
}

extension SetAGoalCheckPointViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel?.savingsGoalData.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GetStartedTableViewCell.reuseIdentifier, for: indexPath) as? GetStartedTableViewCell, let vm = viewModel else { return UITableViewCell() }

        switch viewModel?.viewType {
        case .savingGoal:
            if indexPath.row == 0 {
                cell.setupData(with: vm.savingsGoalData[indexPath.row], clickable: true)
            } else {
                cell.setupData(with: vm.savingsGoalData[indexPath.row], clickable: false)
            }
        case .property:
            if indexPath.row == 2 || indexPath.row == 3 {
                cell.setupData(with: vm.savingsGoalData[indexPath.row], clickable: false)
            } else {
                cell.setupData(with: vm.savingsGoalData[indexPath.row], clickable: true)
            }
        case .deposit:
            if indexPath.row == 3 {
                cell.setupData(with: vm.savingsGoalData[indexPath.row], clickable: false)
            } else {
                cell.setupData(with: vm.savingsGoalData[indexPath.row], clickable: true)
            }
        default:
            cell.setupData(with: vm.savingsGoalData[indexPath.row], clickable: true)
        }
        if let styles {
            cell.style(styles: styles)
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel?.viewType {
        case .savingGoal:
            if indexPath.row == 0 {
                savingsGoal()
            }
        case .property:
            if indexPath.row == 0 {
                savingsGoal()
            }
            if indexPath.row == 1 {
                propertyGoal()
            }
        case .deposit:
            if indexPath.row == 0 {
                savingsGoal()
            }
            if indexPath.row == 1 {
                propertyGoal()
            }
            if indexPath.row == 2 {
                depositGoal()
            }
        default:
            if indexPath.row == 0 {
                savingsGoal()
            }
            if indexPath.row == 1 {
                propertyGoal()
            }
            if indexPath.row == 2 {
                depositGoal()
            }
            if indexPath.row == 3 {
                savingBudget()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel else { return nil }
        let view = tableView.dequeueReusableHeaderFooter(SetAGoalCheckPointTableViewHeader.self)
        view.setup(viewModel: viewModel)
        view.apply(styles: AppStyles.shared)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if viewModel?.viewType == .budget {
            let view = tableView.dequeueReusableHeaderFooter(SetAGoalCheckPointTableViewFooter.self)
            view.setup()
            view.apply(styles: AppStyles.shared)
            
            return view
        }
        
        return nil
    }
}

extension SetAGoalCheckPointViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
