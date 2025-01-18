//
//  StateLoaderViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 20.01.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class StateLoaderViewController: UIViewController, Stylable, ErrorPresenter {
    private let infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: LabelBlue = {
        let label = LabelBlue()
        label.textAlignment = .center
        return label
    }()

    private lazy var tryAgainButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Try again", for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        return button
    }()

    private lazy var createAccountButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Create Account", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(handleCreateAccount), for: .touchUpInside)
        return button
    }()

    var viewModel: StateLoaderViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
        view.accessibilityIdentifier = "StateLoader"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        contentSizeMonitor.removeObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func setupViews() {
        view.backgroundColor = UIColor(hex: "0F0728")

        titleLabel.text = "Checking your details..."
        let logo = UIImage(named: "logo_release", in: uiBundle, compatibleWith: nil) ?? UIImage()
        infoImageView.image = logo

        [infoImageView, titleLabel, tryAgainButton, createAccountButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            infoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80.5),
            infoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoImageView.heightAnchor.constraint(equalToConstant: 220),
            infoImageView.widthAnchor.constraint(equalToConstant: 220),

            titleLabel.topAnchor.constraint(equalTo: infoImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tryAgainButton.bottomAnchor.constraint(equalTo: createAccountButton.topAnchor, constant: -8),
            tryAgainButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tryAgainButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tryAgainButton.heightAnchor.constraint(equalToConstant: 48),

            createAccountButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createAccountButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    func bind() {
        loadViewIfNeeded()

        viewModel = StateLoaderViewModel()
        viewModel?.login(from: self)
        
        setupViews()
        setupListeners()
        
        apply(styles: AppStyles.shared)
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
        
        viewModel?.$nextStep
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] nextStep in
                guard let nextStep else { return }
                self?.navigate(to: nextStep)
                self?.setOnBoardingProcessState(for: nextStep)
            })
            .store(in: &subscriptions)
        
        viewModel?.$presentFailed
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] presentFailed in
                guard let presentFailed, presentFailed else { return }
                self?.presentFailed()
            })
            .store(in: &subscriptions)
    }
    
    func presentFailed() {
        titleLabel.text = "Failed to Sign In"
        tryAgainButton.isHidden = false
        createAccountButton.isHidden = false
        
        viewModel?.session.clearCredentials()
        viewModel?.login(from: self)
    }

    @objc private func handleRetry() {
        tryAgainButton.isHidden = true
        createAccountButton.isHidden = true
        titleLabel.text = "Checking your details..."
        viewModel?.login(from: self)
    }

    @objc private func handleCreateAccount() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let journeyCoordinator = JourneyCoordinator(presenter: presenter)
                journeyCoordinator.start()
            })
        }
    }
    
    private func setOnBoardingProcessState(for nextStep: OnboardingStep) {
        AccountsManager.shared.isOnboardingCategorisationDone = nextStep.isAfterCompleteTransactionProcessing
    }
    
    private func navigate(to nextStep: OnboardingStep) {
        if let presenter = navigationController {
            let getStartedVC = GetStartedViewController()
            let setGoalVC = SetAGoalCheckPointViewController()

            switch nextStep {
            case .acceptTerms:
                presenter.viewControllers = []
                let coordinator = TermsCoordinator(presenter: presenter)
                coordinator.start()
            case .addIncomeInfo:
                getStartedVC.bind(type: .linkedBankAccounts, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                let coordinator = MilestoneInformationCoordinator(presenter: presenter, type: .ownYourFinances)
                coordinator.start()
            case .addSavingsInfo:
                getStartedVC.bind(type: .income, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                let imageView = AppStyles.shared.backgroundImages.defaultImage.imageView
                imageView.frame = presenter.view.bounds
                presenter.view.insertSubview(imageView, at: 0)

                let coordinator = DepositCoordinator(presenter: presenter,
                                                     targetHeight: nil,
                                                     showNextButton: true)
                coordinator.start()
            case .showDashboard:
                let coordinator = DashboardCoordinator(presenter: presenter)
                coordinator.start()
            case .completeOnboarding:
                getStartedVC.bind(type: .goal, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                
                let coordinator = OnboardingCompleteCoordinator(presenter: presenter)
                coordinator.start()
            case .validateSpending:
                getStartedVC.bind(type: .savings, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                
                let coordinator = SpendingConfirmationCoordinator(presenter: presenter, transactions: [], getStartedType: .savings)
                coordinator.start()
            case .completeBudget:
                setGoalVC.bind(goalType: .deposit, isBackAvailable: false)
                presenter.viewControllers = [setGoalVC]
                
                let coordinator = SavingBudgetCoordinator(presenter: presenter, isDashboard: false)
                coordinator.start()
            case .createAccount:
                getStartedVC.bind(type: .initial, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                
                let coordinator = RegistrationCoordinator(presenter: presenter)
                coordinator.start()
            case .linkBankAccounts:
                getStartedVC.bind(type: .registered, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                
                let coordinator = LinkAccountsInformationCoordinator(presenter: presenter)
                coordinator.start()
            case .setAffordability:
                getStartedVC.bind(type: .spending, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                
                let coordinator = MilestoneInformationCoordinator(presenter: presenter, type: .ownYourFuture)
                coordinator.start()
            case .setDepositGoal:
                setGoalVC.bind(goalType: .property, isBackAvailable: false)
                presenter.viewControllers = [setGoalVC]
                let coordinator = SetDepositGoalCoordinator(presenter: presenter)
                coordinator.start()
            case .setPropertyGoal:
                setGoalVC.bind(goalType: .savingGoal, isBackAvailable: false)
                presenter.viewControllers = [setGoalVC]
                
                let coordinator = AffordabilityMainCoordinator(presenter: presenter, type: .setGoal, isDashboard: false)
                coordinator.start()
            case .setSavingsGoal:
                getStartedVC.bind(type: .spending, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                
                let coordinator = GetStartedCoordinator(presenter: presenter, type: .spending)
                coordinator.start()
            case .completeTransactionProcessing:
                let coordinator = SpendingSummaryCoordinator(presenter: presenter, getStartedType: .spending)
                coordinator.start()
            case .verifyEmailAddress:
                guard let userData = viewModel?.userData else { return }
                
                getStartedVC.bind(type: .initial, isBackAvailable: false)
                presenter.viewControllers = [getStartedVC]
                
                let coordinator = EmailVerificationCoordinator(presenter: presenter, data: userData)
                coordinator.start()
            }
        }
    }
}

extension StateLoaderViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
