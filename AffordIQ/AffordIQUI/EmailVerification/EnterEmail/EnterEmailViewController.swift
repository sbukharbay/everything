//
//  EnterEmailViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 30.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class EnterEmailViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private let titleLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Enter email address again"
        return label
    }()

    private lazy var emailField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private let errorLabel = ErrorLabel()

    private lazy var wrappingStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, emailField, errorLabel])
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 8
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
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

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "registration", in: uiBundle, compatibleWith: nil)
        return imageView
    }()

    private let labelHeader: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Change Email"
        return label
    }()

    private lazy var imageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, labelHeader])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.setCustomSpacing(8, after: iconImageView)
        stackView.alignment = .center
        return stackView
    }()

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "", rightButtonTitle: "Done") { [weak self] in
            self?.isClosing = true
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: { [weak self] in
            self?.handleDoneButton()
        }
        return navBar
    }()
    
    private var customAlertView: CustomAlertView?

    var viewModel: EnterEmailViewModel?
    var isSubmitEnabled = false
    var isClosing = false
    var textFieldHandler: FormTextFieldDelegateImpl<EnterEmailViewController>?
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

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    fileprivate func setupViews() {
        [backgroundImageView, blurEffectView, imageStackView, wrappingStackView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: wrappingStackView.bottomAnchor, constant: 48),

            imageStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            imageStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            imageStackView.heightAnchor.constraint(equalToConstant: 30),

            wrappingStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            wrappingStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            wrappingStackView.topAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: 32),
            wrappingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func bind(data: UserRegistrationData?, styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        backgroundImageView.image = styles.backgroundImages.defaultImage.image

        let vm = EnterEmailViewModel(data: data)
        viewModel = vm

        textFieldHandler = FormTextFieldDelegateImpl<EnterEmailViewController>(form: self, viewModel: vm)

        setupViews()
        setupListeners()
        
        if data != nil {
            bringFeedbackButton(String(describing: type(of: self)))
        } else {
            hideFeedbackButton()
        }
        
        self.styles = styles
        apply(styles: styles)
    }

    @objc private func handleDoneButton() {
        view.endEditing(true)
        set(interactionEnabled: false)
        
        let sanitizedValues = values.compactMapValues { $0.sanitized }
        viewModel?.submit(values: sanitizedValues)
    }
    
    private func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.set(interactionEnabled: true)
                self?.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.$userAlreadyExists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exists in
                if exists {
                    self?.registrationError()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$showNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showNext in
                if showNext {
                    self?.showNext()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$showCustomError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showError in
                if showError {
                    self?.showCustomError()
                }
            }
            .store(in: &subscriptions)
    }
    
    func set(interactionEnabled: Bool) {
        view.isUserInteractionEnabled = interactionEnabled
    }
    
    func registrationError() {
        set(interactionEnabled: true)

        guard let style = styles else { return }

        var customAlertView: CustomAlertView?
        customAlertView = CustomAlertView(style: style, title: "SORRY", message: "An account already exists for that email address.", rightButtonTitle: "Ok") {
            customAlertView?.removeFromSuperview()
        }
        
        guard let alertView = customAlertView else { return }

        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    func showNext() {
        if let presenter = navigationController {
            isClosing = true
            if let data = viewModel?.registrationData {
                let getStartedCoordinator = EmailVerificationCoordinator(presenter: presenter, data: data)
                getStartedCoordinator.start()
            } else {
                presenter.popViewController(animated: true)
            }
        }
    }
    
    func showCustomError() {
        set(interactionEnabled: true)
        errorLabel.text = "Please enter a valid email address."
    }
    
    func emailDuplicateError(_ error: String) {
        view.isUserInteractionEnabled = true
        
        guard let style = styles else { return }
        
        customAlertView = CustomAlertView(style: style, title: "SORRY", message: error, rightButtonTitle: "Ok") { [weak self] in
            self?.customAlertView?.removeFromSuperview()
            self?.customNavBar.isUserInteractionEnabled = true
        }
        
        guard let alertView = customAlertView else { return }
        
        customNavBar.isUserInteractionEnabled = false
        
        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

extension EnterEmailViewController: Form {
    typealias FieldType = EmailViewField

    var fields: [UITextField?] {
        [emailField]
    }

    var messages: [UILabel?] {
        [errorLabel]
    }

    var filters: [EmailViewField: (Character) -> Bool] {
        return [:]
    }
}

extension EnterEmailViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
