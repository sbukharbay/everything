//
//  AddMoreAccountsViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 04/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class AddMoreAccountsViewController: FloatingButtonController, Stylable {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Get Started", rightButtonTitle: "Next") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: { [weak self] in
            self?.nextButtonHandle()
        }
        return navBar
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "linked_accounts", in: uiBundle, compatibleWith: nil)
        return imageView
    }()

    private let headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Link Bank Accounts"
        return label
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, headerLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.setCustomSpacing(16, after: iconImageView)
        return stackView
    }()

    private let descriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Do you have any other accounts held at other institutions?\n\n\nPlease add them now before continuing."
        label.numberOfLines = 0
        return label
    }()

    private lazy var addAccountsButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Add More Accounts", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(addAccountsOnButtonTap), for: .touchUpInside)
        return button
    }()

    var viewModel: AddMoreAccountsViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()

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

    func bind(getStartedType: GetStartedViewType? = nil, isSettings: Bool = false) {
        loadViewIfNeeded()

        viewModel = AddMoreAccountsViewModel(getStartedType: getStartedType, isSettings: isSettings)
        setupViews()
        apply(styles: AppStyles.shared)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    func nextButtonHandle() {
        if let viewModel, 
            viewModel.isOnboardingCategorisationDone ||
            viewModel.session.isOnboardingCompleted {
            showAlfiLoader()
        } else {
            showGetStarted()
        }
    }

    @objc func addAccountsOnButtonTap() {
        if let presenter = navigationController, let viewModel {
            let chooseProviderCoordinator = ChooseProviderCoordinator(presenter: presenter, isSettings: viewModel.isSettings, getStartedType: viewModel.getStartedType)
            chooseProviderCoordinator.start()
        }
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
        [backgroundImageView, blurEffectView, horizontalStackView, descriptionLabel, addAccountsButton, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: addAccountsButton.bottomAnchor, constant: 48),

            horizontalStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            horizontalStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: 32),
            descriptionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),
            descriptionLabel.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            addAccountsButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            addAccountsButton.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            addAccountsButton.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            addAccountsButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func showGetStarted() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                if viewModel.session.isOnboardingCompleted {
                    if let vc = presenter.viewControllers.last(where: { $0.isKind(of: GetStartedViewController.self) }), let accountVC = vc as? GetStartedViewController {
                        presenter.popToViewController(accountVC, animated: true)
                    }
                } else {
                    let coordinator = GetStartedCoordinator(presenter: presenter, type: viewModel.getStartedType)
                    coordinator.start()
                }
            })
        }
    }
    
    func showAlfiLoader() {
        if let presenter = navigationController, let viewModel {
            let coordinator = AlfiLoaderCoordinator(presenter: presenter, getStartedType: viewModel.getStartedType)
            coordinator.start()
        }
    }
    
    private func backToSettings() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                if viewModel.session.isOnboardingCompleted {
                    if let vc = presenter.viewControllers.last(where: { $0.isKind(of: DashboardSettingsViewController.self) }), let accountVC = vc as? DashboardSettingsViewController {
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

extension AddMoreAccountsViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
