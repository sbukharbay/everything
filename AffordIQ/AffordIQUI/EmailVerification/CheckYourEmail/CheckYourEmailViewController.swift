//
//  CheckYourEmailViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 01.12.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class CheckYourEmailViewController: UIViewController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "email", in: uiBundle, compatibleWith: nil))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "72F0F0")
        return imageView
    }()

    private let titleLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Check Your Email"
        return label
    }()

    private lazy var topStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .bottom
        view.spacing = 0
        return view
    }()

    private lazy var emailLabel = FieldLabelBoldDark()

    private lazy var backgroundDarkView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "0F0728")
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        return view
    }()

    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = UIColor(hex: "72F0F0")
        button.addTarget(self, action: #selector(onCheckButtonTap), for: .touchUpInside)
        return button
    }()

    private let confirmLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "I have confirmed my email address"
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.textAlignment = .left
        
        return label
    }()

    private let errorLabel: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Unconfirmed, check your email."
        label.numberOfLines = 0
        label.textAlignment = .left
        
        return label
    }()

    private lazy var bodyStackView: UIStackView = {
        let emailStack = UIStackView(arrangedSubviews: [getLabel(with: "We have sent you an email to"), emailLabel])
        emailStack.axis = .vertical

        let view = UIStackView(arrangedSubviews: [
            emailStack,
            getLabel(with: "You have to open the email and select confirm before you can proceed."),
            getLabel(with: "You can enter your email address again if you got it wrong."),
            getLabel(with: "Your email might take a few minutes to arrive. If you do not get an email, check your spam folder.")
        ])
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 16
        return view
    }()

    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [nextButton, enterEmailButton])
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 8
        return view
    }()

    private lazy var nextButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(handleNextButton), for: .touchUpInside)
        button.isEnabled = checked
        return button
    }()

    private lazy var enterEmailButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Enter email again", for: .normal)
        button.setTitleColor(UIColor(hex: "72F0F0"), for: .normal)
        button.addTarget(self, action: #selector(handleEnterEmailButton), for: .touchUpInside)
        return button
    }()

    private var viewModel: CheckYourEmailViewModel?
    private var checked = false
    private var contentSizeMonitor: ContentSizeMonitor = .init()
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

    fileprivate func setupViews() {
        errorLabel.isHidden = true

        [backgroundImageView, backgroundDarkView, topStackView, bodyStackView, checkButton, confirmLabel, errorLabel, buttonStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backgroundDarkView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundDarkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundDarkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundDarkView.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 24),

            topStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            topStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topStackView.heightAnchor.constraint(equalToConstant: 30),

            bodyStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 24),
            bodyStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            bodyStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            checkButton.topAnchor.constraint(equalTo: bodyStackView.bottomAnchor, constant: 24),
            checkButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            checkButton.heightAnchor.constraint(equalToConstant: 26),
            checkButton.widthAnchor.constraint(equalToConstant: 26),

            confirmLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            confirmLabel.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            confirmLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            errorLabel.topAnchor.constraint(equalTo: confirmLabel.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: confirmLabel.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: confirmLabel.trailingAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: confirmLabel.centerXAnchor),

            buttonStackView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(onCheckButtonTap))
        confirmLabel.addGestureRecognizer(labelTap)
    }

    func bind(data: UserRegistrationData) {
        loadViewIfNeeded()

        emailLabel.text = data.username

        backgroundImageView.image = AppStyles.shared.backgroundImages.defaultImage.image

        viewModel = CheckYourEmailViewModel(data: data)
        
        setupListeners()
        setupViews()
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
        
        // Listener shows warning message if showError not nil
        viewModel?.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showView in
                if showView {
                    self?.showError()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$showTermsView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showView in
                if showView {
                    self?.showTermsView()
                }
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

    @objc func onCheckButtonTap() {
        checked.toggle()

        if checked {
            checkButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            nextButton.isEnabled = true
            errorLabel.isHidden = true
        } else {
            checkButton.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
            nextButton.isEnabled = false
        }
    }

    @objc private func handleEnterEmailButton() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = EnterEmailCoordinator(presenter: presenter, data: self.viewModel?.registrationData)
                coordinator.start()
            })
        }
    }

    @objc private func handleNextButton() {
        Task {
            await viewModel?.emailConfirmed()
        }
    }

    func showError() {
        onCheckButtonTap()
        errorLabel.isHidden = false
    }
    
    func showNext() {
        if let presenter = navigationController {
            if let registrationVC = presenter.viewControllers.last(where: { $0 is RegistrationViewController }) {
                presenter.popToViewController(registrationVC, animated: true)
            }
        }
    }
    
    func showTermsView() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = TermsCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }
}

extension CheckYourEmailViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
