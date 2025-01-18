//
//  EmailVerificationViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 29.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class EmailVerificationViewController: UIViewController, Stylable, ErrorPresenter {
    private lazy var emailConfirmedButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("I have confirmed my email", for: .normal)
        button.addTarget(self, action: #selector(handleEmailConfirmedButton), for: .touchUpInside)
        button.titleLabel?.numberOfLines = 0
        return button
    }()

    private lazy var enterEmailButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Enter email again", for: .normal)
        button.addTarget(self, action: #selector(handleEnterEmailButton), for: .touchUpInside)
        return button
    }()

    private lazy var emailLabel = FieldLabelBoldDark()

    private lazy var wrappingStackView: UIStackView = {
        let emailStack = UIStackView(arrangedSubviews: [getLabel(with: "We have sent you an email to"), emailLabel])
        emailStack.axis = .vertical

        let view = UIStackView(arrangedSubviews: [
            emailStack,
            getLabel(with: "Select confirm in the email and come back to this screen."),
            emailConfirmedButton,
            getLabel(with: "You can enter your email address again if you got it wrong."),
            enterEmailButton,
            getLabel(with: "Your email might take a few minutes to arrive. If you do not get an email, check your spam folder.")
        ])

        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 16

        return view
    }()

    private lazy var themeImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let registrationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "registration", in: uiBundle, compatibleWith: nil)
        return imageView
    }()

    private let registrationTitle: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Registration"
        return label
    }()

    private lazy var imageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [registrationIcon, registrationTitle])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.setCustomSpacing(8, after: registrationIcon)
        stackView.alignment = .center
        return stackView
    }()

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Get Started") { [weak self] in
            self?.backToRegistration()
        }
        return navBar
    }()

    var viewModel: EmailVerificationViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    private var styles: AppStyles?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
        [themeImageView, blurEffectView, imageStackView, wrappingStackView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            themeImageView.topAnchor.constraint(equalTo: view.topAnchor),
            themeImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            themeImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            themeImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: wrappingStackView.bottomAnchor, constant: 48),

            imageStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            imageStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            imageStackView.heightAnchor.constraint(equalToConstant: 30),

            wrappingStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            wrappingStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            wrappingStackView.topAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: 16),
            wrappingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            emailConfirmedButton.heightAnchor.constraint(equalToConstant: 40),
            enterEmailButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func bind(styles: AppStyles = AppStyles.shared, data: UserRegistrationData) {
        loadViewIfNeeded()

        emailLabel.text = data.username
        themeImageView.image = styles.backgroundImages.defaultImage.image

        viewModel = EmailVerificationViewModel(data: data)

        setupListeners()
        setupViews()
        self.styles = styles
        apply(styles: styles)
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
        
        viewModel?.$showCheckEmailView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showView in
                guard showView else { return }
                self?.showCheckEmailView()
            }
            .store(in: &subscriptions)
        
        viewModel?.$showTermsView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showView in
                guard showView else { return }
                self?.showTermsView()
            }
            .store(in: &subscriptions)
        
        viewModel?.$showNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showView in
                if showView {
                    self?.showNext()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading && !BusyView.shared.isPresented {
                    self.showLoadingState(withMessage: "Loading...")
                } else {
                    self.hideLoadingState()
                }
            }
            .store(in: &subscriptions)
    }
    
    func showLoadingState(withMessage message: String) {
        guard let navigationController else { return }
        BusyView.shared.show(
            navigationController: navigationController,
            title: NSLocalizedString(message, bundle: uiBundle, comment: message),
            fullScreen: false
        )
    }
    
    func hideLoadingState() {
        BusyView.shared.hide()
    }
    
    private func getLabel(with text: String) -> FieldLabelDark {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        label.text = text

        return label
    }

    @objc private func handleEnterEmailButton() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = EnterEmailCoordinator(presenter: presenter, data: self.viewModel?.registrationData)
                coordinator.start()
            })
        }
    }
    
    func showCheckEmailView() {
        guard let data = viewModel?.registrationData, let presenter = navigationController else { return }
        
        presenter.dismiss(animated: true, completion: {
            let coordinator = CheckYourEmailCoordinator(presenter: presenter, data: data)
            coordinator.start()
        })
    }
    
    func backToRegistration() {
        guard let data = viewModel?.registrationData, let presenter = navigationController else { return }

        presenter.dismiss(animated: true, completion: {
            let coordinator = RegistrationCoordinator(presenter: presenter, data: data)
            coordinator.start()
        })
    }
    
    func showTermsView() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = TermsCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }
    
    func showNext() {
        if let presenter = navigationController {
            if let registrationVC = presenter.viewControllers.last(where: { $0 is RegistrationViewController }) {
                presenter.popToViewController(registrationVC, animated: true)
            }
        }
    }

    @objc private func handleEmailConfirmedButton() {
        Task {
            await viewModel?.emailConfirmed()
        }
    }
}

extension EmailVerificationViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
