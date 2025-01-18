//
//  RegistrationViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 21/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class RegistrationViewController: FloatingButtonController {
    @IBOutlet var emailAddress: UITextField?
    @IBOutlet var givenName: UITextField?
    @IBOutlet var familyName: UITextField?
    @IBOutlet var mobileNumber: UITextField?
    @IBOutlet var password: UITextField?
    @IBOutlet var confirmPassword: UITextField?
    @IBOutlet var dateOfBirth: UITextField?
    @IBOutlet var passwordRulesVStackView: UIStackView!
    
    @IBOutlet weak var titleLabel: HeadingTitleLabel!
    @IBOutlet var dateOfBirthError: UILabel?
    @IBOutlet var emailAddressError: UILabel?
    @IBOutlet var givenNameError: UILabel?
    @IBOutlet var familyNameError: UILabel?
    @IBOutlet var mobileNumberError: UILabel?
    @IBOutlet var confirmPasswordError: UILabel?
    
    @IBOutlet var passwordTitleLabel: UILabel?
    @IBOutlet var confirmPasswordTitleLabel: UILabel?
    
    @IBOutlet var subTitleLabel: UILabel?
    @IBOutlet var submitButton: UIButton?
    
    @IBOutlet var fieldsStackView: UIStackView!
    @IBOutlet var scrollView: FormScrollView!
    @IBOutlet var backgroundBlurView: UIVisualEffectView!
    @IBOutlet var blurViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var blurViewTopConstraint: NSLayoutConstraint!
    
    let minimumAge: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    let minimumDate: Date? = Calendar.current.date(byAdding: .year, value: -65, to: Date())
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.addTarget(self, action: #selector(dateChanged), for: .allEvents)
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.datePickerMode = .date
        picker.maximumDate = minimumAge
        picker.minimumDate = minimumDate
        return picker
    }()
    
    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Get Started") { [weak self] in
            self?.complete()
        }
        return navBar
    }()
    
    private let emailLabel = FieldLabelDark()
    
    private lazy var changeEmailButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Change Email", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(changeEmail), for: .touchUpInside)
        return button
    }()
    
    private lazy var resetButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Reset Password", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Delete Account", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor(hex: "72F0F0"), for: .normal)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var hidePasswordButton: UIButton = {
        let image = UIImage(systemName: "eye.fill")?
            .withRenderingMode(.alwaysTemplate)
        let view = UIButton()
        view.setImage(image, for: .normal)
        view.tintColor = .white
        view.layer.opacity = 0.7
        view.addTarget(self, action: #selector(handleHidePasswordButtonClick), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var hideConfirmPasswordButton: UIButton = {
        let image = UIImage(systemName: "eye.fill")?
            .withRenderingMode(.alwaysTemplate)
        let view = UIButton()
        view.setImage(image, for: .normal)
        view.tintColor = .white
        view.layer.opacity = 0.7
        view.addTarget(self, action: #selector(handleHideConfirmPasswordButtonClick), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var lengthPasswordRule: RegistrationPasswordRuleView = {
        let view = RegistrationPasswordRuleView()
        view.configure(rule: .length)
        
        return view
    }()
    
    private(set) lazy var lowerCasePasswordRule: RegistrationPasswordRuleView = {
        let view = RegistrationPasswordRuleView()
        view.configure(rule: .lowerCase)
        
        return view
    }()
    
    private(set) lazy var upperCasePasswordRule: RegistrationPasswordRuleView = {
        let view = RegistrationPasswordRuleView()
        view.configure(rule: .upperCase)
        
        return view
    }()
    
    private(set) lazy var numberPasswordRule: RegistrationPasswordRuleView = {
        let view = RegistrationPasswordRuleView()
        view.configure(rule: .number)
        
        return view
    }()
    
    private(set) lazy var repeatingCharsPasswordRule: RegistrationPasswordRuleView = {
        let view = RegistrationPasswordRuleView()
        view.configure(rule: .repeatingChars)
        
        return view
    }()
    
    private var customAlertView: CustomAlertView?

    var viewModel: RegistrationViewModel?
    private var styles: AppStyles?
    private var subscriptions = Set<AnyCancellable>()
    
    private var didShowPassword: Bool = false
    private var didShowConfirmPassword: Bool = false

    var isClosing = false

    var textFieldHandler: FormTextFieldDelegateImpl<RegistrationViewController>?
}

extension RegistrationViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}

extension RegistrationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let viewModel {
            Task {
                await viewModel.getUserData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupPasswordView()
        setupConfirmPasswordView()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func setupPasswordView() {
        password?.addTarget(self, action: #selector(passwordFieldDidChange), for: .editingChanged)
        password?.addTarget(self, action: #selector(passwordTextEndEditing), for: .editingDidEnd)
        password?.addTarget(self, action: #selector(textFieldShouldBeginEditing), for: .editingDidBegin)
        password?.addTarget(self, action: #selector(confirmPasswordShouldEndEditing), for: .editingDidEnd)
    }
    
    private func setupConfirmPasswordView() {
        confirmPassword?.addTarget(self, action: #selector(textFieldShouldBeginEditing), for: .editingDidBegin)
        confirmPassword?.addTarget(self, action: #selector(confirmPasswordShouldEndEditing), for: .editingDidEnd)
        confirmPassword?.addTarget(self, action: #selector(confirmPasswordShouldEndEditing), for: .editingChanged)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupSubviews()
        setupVStackView()
    }

    func setupVStackView() {
        passwordRulesVStackView.spacing = 4
        passwordRulesVStackView.alignment = .fill
        passwordRulesVStackView.distribution = .fill
    }
    
    func bind(data: UserRegistrationData?,
              styles: AppStyles = AppStyles.shared,
              isSettings: Bool) {
        loadViewIfNeeded()

        let viewModel = RegistrationViewModel(view: self, data: data)
        self.viewModel = viewModel
        setupListeners()
        
        password?.passwordRules = UITextInputPasswordRules(descriptor: viewModel.passwordRules.stringRepresentation)
        clearMessages()
        
        if data != nil {
            setupFields()
            bringFeedbackButton(String(describing: type(of: self)))
        } else {
            hideFeedbackButton()
        }
        
        textFieldHandler = FormTextFieldDelegateImpl<RegistrationViewController>(form: self, viewModel: viewModel)

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        dateOfBirth?.inputAccessoryView = toolBar
        dateOfBirth?.inputView = datePicker

        view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false

        blurViewTopConstraint.isActive = false
        NSLayoutConstraint.activate([
            backgroundBlurView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16)
        ])

        if isSettings {
            customNavBar.removeBlurView()
            customNavBar.setTitle(text: "")
            titleLabel.text = "Account Details"
        }

        self.styles = styles
        apply(styles: styles)
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    func close() {
        isClosing = true
        view.endEditing(true)
    }
    
    private func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error, let self else { return }
                self.present(error: error)
            }
            .store(in: &subscriptions)
        
        // Update view when user data changed
        viewModel?.$registrationData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let data, let self else { return }
                self.setupFields()
                self.bringFeedbackButton(String(describing: type(of: self)))
                self.setFields(with: data)
            }
            .store(in: &subscriptions)
        
        // Wait for subject sends result
        viewModel?.resetPasswordSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.resetPasswordError(title: "SORRY", errorDescription: error.localizedDescription)
                case .finished:
                    self?.resetPasswordSucceeded()
                }
            } receiveValue: { [weak self] _ in
                self?.resetPasswordSucceeded()
            }
            .store(in: &subscriptions)
        
        // Wait for subject send deletion success result
        viewModel?.deleteAccountSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.deleteAccountSucceeded()
            }
            .store(in: &subscriptions)
        
        // Wait for subject send regestration success result
        viewModel?.registrationSucceedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.registrationSucceeded()
            }
            .store(in: &subscriptions)
        
        // Wait for subject send complete result
        viewModel?.completeSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.complete()
            }
            .store(in: &subscriptions)
        
        // If user exists subscription will fire alert
        viewModel?.$registrationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] description in
                guard let self, !description.isEmpty else { return }
                self.registrationError(error: description)
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading && !BusyView.shared.isPresented {
                    self.showLoadingState(withMessage: "Preparing Data")
                } else {
                    self.hideLoadingState()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$isDeleting
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isDeleting in
                guard let self else { return }
                if isDeleting && !BusyView.shared.isPresented {
                    self.showLoadingState(withMessage: "Deleting your account...")
                } else {
                    self.hideLoadingState()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$isSendingData
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isSending in
                guard let self else { return }
                if isSending && !BusyView.shared.isPresented {
                    self.showLoadingState(withMessage: "Loading")
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

    func setupFields() {
        customNavBar.addRightButton(title: "Update") { [weak self] in
            self?.update()
        }

        submitButton?.isHidden = true
        password?.isHidden = true
        passwordRulesVStackView?.isHidden = true
        passwordTitleLabel?.isHidden = true
        confirmPassword?.isHidden = true
        confirmPasswordError?.isHidden = true
        confirmPasswordTitleLabel?.isHidden = true
        subTitleLabel?.isHidden = true
        emailAddress?.isHidden = true

        [emailLabel, changeEmailButton, resetButton, deleteButton].forEach {
            fieldsStackView.addArrangedSubview($0)
        }

        if let styles {
            apply(styles: styles)
        }

        blurViewBottomConstraint?.isActive = false
        NSLayoutConstraint.activate([
            backgroundBlurView.bottomAnchor.constraint(equalTo: fieldsStackView.bottomAnchor, constant: 24)
        ])
    }

    func setFields(with data: UserRegistrationData) {
        givenName?.text = data.firstName
        familyName?.text = data.lastName
        mobileNumber?.text = data.mobilePhone
        dateOfBirth?.text = data.dateOfBirth
        emailLabel.text = data.username
    }

    func update() {
        guard let dateOfBirth = dateOfBirth?.text?.changeDOBDateFormat(),
              let mobileNumber = mobileNumber?.text,
              let familyName = familyName?.text,
              let givenName = givenName?.text,
              let viewModel
        else { return }
        
        let values: [ViewModelType.FieldType: String] = [
            .givenName: givenName,
            .familyName: familyName,
            .dateOfBirth: dateOfBirth,
            .mobileNumber: mobileNumber
        ]
        
        view.endEditing(true)
        
        let sanitizedValues = values.compactMapValues { $0.sanitized }
        let ok = viewModel.isValid(values: sanitizedValues)
        
        guard ok else { return }
        
        Task {
            await viewModel.updateAccount(dateOfBirth: dateOfBirth, mobileNumber: mobileNumber, familyName: familyName, givenName: givenName)
        }
    }

    @objc private func handleDelete() {
        guard let styles else { return }

        var alertView: CustomAlertView!
        alertView = CustomAlertView(
            style: styles,
            title: "Delete Account",
            message: "Are you sure you want to permanently delete your affordIQ account?",
            rightButtonTitle: "Delete",
            leftButtonTitle: "Cancel") { [weak self] in
                Task {
                    await self?.viewModel?.deleteAccount()
                }
                alertView.removeFromSuperview()
                self?.removeView()
        } leftButtonAction: { [weak self] in
            alertView.removeFromSuperview()
            self?.removeView()
        }

        scrollView.isUserInteractionEnabled = false
        customNavBar.isUserInteractionEnabled = false

        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    @objc private func handleReset() {
        scrollView.isUserInteractionEnabled = false
        customNavBar.isUserInteractionEnabled = false
        Task {
            await viewModel?.resetPassword()
        }
    }

    @objc private func changeEmail() {
        navigateToChangeEmail()
    }

    @objc func dateChanged() {
        dateOfBirth?.text = datePicker.date.asStringDDMMYYYY()
    }

    @objc func datePickerDone() {
        dateOfBirth?.resignFirstResponder()
    }
    
    @objc func passwordFieldDidChange(_ textField: UITextField) {
        setPasswordRuleStatus(.neutral, textField: textField)
    }
    
    @objc func passwordTextEndEditing(_ textField: UITextField) {
        setPasswordRuleStatus(.fail, textField: textField)
        textFieldShouldEndEditing(textField)
    }
    
    func setPasswordRuleStatus(_ negativeStatus: RegistrationPasswordRuleStatus, textField: UITextField) {
        guard let password = textField.text else { return }
        
        // Length check
        let rule = PasswordRules(rules: [.minLength(8)])
        let lengthStatus: RegistrationPasswordRuleStatus = rule.validate(password: password) ? .pass : .fail
        lengthPasswordRule.setStatus(lengthStatus)
        
        // Lower case check
        let lowerCaseStatus: RegistrationPasswordRuleStatus = CharacterSet.lowercaseLetters.contains(anyCharacterFrom: password) ? .pass : .fail
        lowerCasePasswordRule.setStatus(lowerCaseStatus)
        
        // Upper case check
        let upperCaseStatus: RegistrationPasswordRuleStatus = CharacterSet.uppercaseLetters.contains(anyCharacterFrom: password) ? .pass : .fail
        upperCasePasswordRule.setStatus(upperCaseStatus)
        
        // Numbers check
        let numberStatus: RegistrationPasswordRuleStatus = CharacterSet.decimalDigits.contains(anyCharacterFrom: password) ? .pass : .fail
        numberPasswordRule.setStatus(numberStatus)
        
        // Repeating chars check
        let repeatingCharsStatus: RegistrationPasswordRuleStatus = password.maxConsecutive <= 2 ? .pass : .fail
        repeatingCharsPasswordRule.setStatus(repeatingCharsStatus)
    }
    
    @objc func confirmPasswordShouldEndEditing(_ textField: UITextField) {
        if let passwordText = password?.text,
           let confirmText = confirmPassword?.text,
           !confirmText.isEmpty &&
            confirmText != passwordText {
            let warning = viewModel?.validationMessage(
                field: .confirmPassword,
                values: [.password: passwordText, .confirmPassword: confirmText]
            )
            
            confirmPasswordError?.text = warning
            confirmPasswordError?.isHidden = false
            (confirmPassword as? StandardTextField)?.focusState = .focusedError
            (password as? StandardTextField)?.focusState = .focusedError
        } else {
            confirmPasswordError?.text = ""
            confirmPasswordError?.isHidden = true
            (confirmPassword as? StandardTextField)?.focusState = .normal
            (password as? StandardTextField)?.focusState = .normal
        }
        
        textFieldShouldEndEditing(textField)
    }
    
    @objc func textFieldShouldBeginEditing(_ textField: UITextField) {
        // Setup hide/show password buttons
        switch textField {
        case password:
            hidePasswordButton.layer.opacity = 1.0
        case confirmPassword:
            hideConfirmPasswordButton.layer.opacity = 1.0
        default:
            break
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) {
        // Setup hide/show password buttons
        switch textField {
        case password:
            hidePasswordButton.layer.opacity = 0.7
        case confirmPassword:
            hideConfirmPasswordButton.layer.opacity = 0.7
        default:
            break
        }
    }

    func complete() {
        close()
        
        if let navigationController, let vc = navigationController.viewControllers.last(where: { $0.isKind(of: DashboardSettingsViewController.self) }), let settingsVC = vc as? DashboardSettingsViewController {
            settingsVC.reload()
            navigationController.popToViewController(settingsVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func navigateToChangeEmail() {
        perform(action: { _ in
            if let presenter = navigationController {
                presenter.dismiss(animated: true, completion: {
                    let coordinator = EnterEmailCoordinator(presenter: presenter, data: nil)
                    coordinator.start()
                })
            }
        })
    }
    
    func showEmailConfirmationView() {
        guard let viewModel else { return }
        perform { _ in
            if let presenter = navigationController {
                presenter.dismiss(animated: true, completion: {
                    if let data = viewModel.registrationData {
                        let coordinator = EmailVerificationCoordinator(presenter: presenter, data: data)
                        coordinator.start()
                    }
                })
            }
        }
    }
    
    func login() {
        perform(action: { _ in
            if let presenter = navigationController {
                presenter.dismiss(animated: true, completion: {
                    let coordinator = StateLoaderCoordinator(presenter: presenter)
                    coordinator.start()
                })
            }
        })
    }
    
    // MARK: - Actions
    @objc private func handleHidePasswordButtonClick() {
        didShowPassword.toggle()
        
        if didShowPassword {
            let image = UIImage(systemName: "eye.slash.fill")
            hidePasswordButton.setImage(image, for: .normal)
            password?.isSecureTextEntry = false
        } else {
            let image = UIImage(systemName: "eye.fill")
            hidePasswordButton.setImage(image, for: .normal)
            password?.isSecureTextEntry = true
        }
    }
    
    @objc private func handleHideConfirmPasswordButtonClick() {
        didShowConfirmPassword.toggle()
        
        if didShowConfirmPassword {
            let image = UIImage(systemName: "eye.slash.fill")
            hideConfirmPasswordButton.setImage(image, for: .normal)
            confirmPassword?.isSecureTextEntry = false
        } else {
            let image = UIImage(systemName: "eye.fill")
            hideConfirmPasswordButton.setImage(image, for: .normal)
            confirmPassword?.isSecureTextEntry = true
        }
    }
}

extension RegistrationViewController {
    @IBAction func register(_: Any?) {
        submit()
        AccountsManager.shared.cleanDatabase()
    }
}

extension RegistrationViewController: StoryboardInstantiable {
    static func instantiate() -> Self? {
        return instantiate(storyboard: "Registration", identifier: nil)
    }
}

extension RegistrationViewController: RegistrationView {
    func deleteAccountSucceeded() {
        viewModel?.userSession.logout { [weak self] error in
            if let error = error {
                self?.view.isUserInteractionEnabled = true

                switch error {
                case SessionError.cancelled:
                    break
                default:
                    self?.present(error: error)
                }
                return
            }
        }

        viewModel?.userSession.clearCredentials()
        viewModel?.userSession.userID = nil
        AccountsManager.shared.cleanDatabase()
        NotificationManager.shared.cleanCounterBadge()
        
        guard let styles else { return }

        var confirmationAlertView: ConfirmationAlertView!
        confirmationAlertView = ConfirmationAlertView(style: styles, title: "Your account has been deleted.", buttonTitle: "Ok", buttonAction: {
            confirmationAlertView.removeFromSuperview()
            
            let rootCoordinator = RootCoordinator()
            rootCoordinator.start()
        })

        guard let alertView = confirmationAlertView else { return }

        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func present(error: Error) {
        resetPasswordMessage(title: "Error", description: error.localizedDescription)
    }

    func resetPasswordSucceeded() {
        resetPasswordMessage(title: "RESET PASSWORD", description: "We have sent you an email with a link to reset your password.")
    }
    
    func resetPasswordError(title: String, errorDescription: String) {
        resetPasswordMessage(title: title, description: errorDescription)
    }

    func resetPasswordMessage(title: String, description: String) {
        view.isUserInteractionEnabled = true

        guard let styles else { return }

        customAlertView = CustomAlertView(style: styles, title: title, message: description, rightButtonTitle: "Ok") { [weak self] in
            self?.customAlertView?.removeFromSuperview()
            self?.removeView()
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

    func registrationError(error: String) {
        view.isUserInteractionEnabled = true

        guard let styles else { return }

        customAlertView = CustomAlertView(style: styles, title: "SORRY", message: error, rightButtonTitle: "Sign In", leftButtonTitle: "Back") { [weak self] in
            self?.login()
        } leftButtonAction: { [weak self] in
            self?.customAlertView?.removeFromSuperview()
            self?.removeView()
        }

        guard let alertView = customAlertView else { return }

        scrollView.isUserInteractionEnabled = false
        customNavBar.isUserInteractionEnabled = false

        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func removeView() {
        scrollView.isUserInteractionEnabled = true
        customNavBar.isUserInteractionEnabled = true
    }

    func registrationSucceeded() {
        close()
        showEmailConfirmationView()
        view.isUserInteractionEnabled = true
    }
}

extension RegistrationViewController {
    func isValidForMobileNumber(_ character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) }
            || character == "+"
            || character == " "
    }
}

extension RegistrationViewController: Form {
    typealias FieldType = RegistrationViewField

    var fields: [UITextField?] {
        [givenName, familyName, mobileNumber, dateOfBirth, emailAddress, password, confirmPassword]
    }

    var messages: [UILabel?] {
        [givenNameError, familyNameError, mobileNumberError, dateOfBirthError, emailAddressError, confirmPasswordError]
    }

    var isSubmitEnabled: Bool {
        get {
            return submitButton?.isEnabled ?? false
        }
        set {
            submitButton?.isEnabled = newValue
        }
    }

    var filters: [RegistrationViewField: (Character) -> Bool] {
        return [.mobileNumber: isValidForMobileNumber(_:)]
    }
}

// MARK: - Constraints
extension RegistrationViewController {
    func setupSubviews() {
        embedSubviews()
        setSubviewsConstraints()
    }
    
    func embedSubviews() {
        password?.addSubview(hidePasswordButton)
        confirmPassword?.addSubview(hideConfirmPasswordButton)
        
        passwordRulesVStackView.addArrangedSubview(lengthPasswordRule)
        passwordRulesVStackView.addArrangedSubview(lowerCasePasswordRule)
        passwordRulesVStackView.addArrangedSubview(upperCasePasswordRule)
        passwordRulesVStackView.addArrangedSubview(numberPasswordRule)
        passwordRulesVStackView.addArrangedSubview(repeatingCharsPasswordRule)
    }
    
    func setSubviewsConstraints() {
        setHidePasswordButtonConstraints()
        setHideConfirmPasswordButtonConstraints()
    }
    
    private func setHidePasswordButtonConstraints() {
        guard let password else { return }
        
        NSLayoutConstraint.activate([
            hidePasswordButton.topAnchor.constraint(equalTo: password.topAnchor),
            hidePasswordButton.bottomAnchor.constraint(equalTo: password.bottomAnchor),
            hidePasswordButton.trailingAnchor.constraint(equalTo: password.trailingAnchor, constant: -12)
        ])
    }
    
    private func setHideConfirmPasswordButtonConstraints() {
        guard let confirmPassword else { return }
        
        NSLayoutConstraint.activate([
            hideConfirmPasswordButton.topAnchor.constraint(equalTo: confirmPassword.topAnchor),
            hideConfirmPasswordButton.bottomAnchor.constraint(equalTo: confirmPassword.bottomAnchor),
            hideConfirmPasswordButton.trailingAnchor.constraint(equalTo: confirmPassword.trailingAnchor, constant: -12)
        ])
    }
}
