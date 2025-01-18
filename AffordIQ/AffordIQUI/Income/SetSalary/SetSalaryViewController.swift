//
//  SetSalaryViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class SetSalaryViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Own Your Finances") { [weak self] in
            self?.backButtonHandle()
        }
        return navBar
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        return view
    }()

    private let incomeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "income", in: uiBundle, with: nil)
        return imageView
    }()

    private let titleLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Income"
        return label
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incomeImageView, titleLabel])
        stackView.distribution = .fill
        stackView.setCustomSpacing(12, after: incomeImageView)
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        return stackView
    }()

    private let salaryLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Annual Base Salary (Before Tax)"
        label.numberOfLines = 0
        return label
    }()

    private let informationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#72F0F0")
        imageView.image = UIImage(systemName: "info.circle")
        return imageView
    }()

    private let descriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "This includes commissions, overtime, bonuses & allowances paid over the last year."
        label.numberOfLines = 0
        return label
    }()

    private let bonusLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Additional Work Payments (Yearly, Before Tax)"
        label.numberOfLines = 0
        return label
    }()

    private lazy var salaryField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.placeholder = "£"
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var bonusField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.placeholder = "£"
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private let monthlyLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Monthly Take Home Pay"
        label.numberOfLines = 0
        return label
    }()

    private lazy var monthlyField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.placeholder = "£"
        textField.addTarget(self, action: #selector(monthlyTextFieldDidChange), for: .editingChanged)
        return textField
    }()

    private let monthlyInformationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#72F0F0")
        imageView.image = UIImage(systemName: "info.circle")
        return imageView
    }()

    private let monthlyDescriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "This is the money you receive from your employer each month, after tax has been deducted."
        label.numberOfLines = 0
        return label
    }()

    private lazy var monthlyInfomationalStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [monthlyInformationImageView, monthlyDescriptionLabel])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.setCustomSpacing(12, after: monthlyInformationImageView)
        stack.alignment = .top
        return stack
    }()
    
    private let annualError: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Consider Revising"
        label.isHidden = true
        return label
    }()
    
    private let monthlyError: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Consider Revising"
        label.isHidden = true
        return label
    }()
    
    private var customAlertView: CustomAlertView?

    var viewModel: SetSalaryViewModel?
    private var showNext = true
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

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    fileprivate func setupViews() {
        [backgroundImageView, blurEffectView, topStackView,
         salaryLabel, salaryField, annualError,
         informationImageView, descriptionLabel, bonusLabel,
         bonusField, monthlyLabel, monthlyField,
         monthlyError, monthlyInfomationalStackView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.bottomAnchor.constraint(equalTo: monthlyInfomationalStackView.bottomAnchor, constant: 24),

            incomeImageView.heightAnchor.constraint(equalToConstant: 32),
            incomeImageView.widthAnchor.constraint(equalToConstant: 32),

            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            topStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            salaryLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            salaryLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            salaryLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 32),

            salaryField.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            salaryField.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            salaryField.topAnchor.constraint(equalTo: salaryLabel.bottomAnchor, constant: 4),
            salaryField.heightAnchor.constraint(equalToConstant: 40),

            annualError.topAnchor.constraint(equalTo: salaryField.bottomAnchor, constant: 4),
            annualError.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            annualError.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            informationImageView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            informationImageView.topAnchor.constraint(equalTo: bonusField.bottomAnchor, constant: 24),

            descriptionLabel.leadingAnchor.constraint(equalTo: informationImageView.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: bonusField.bottomAnchor, constant: 24),

            bonusLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            bonusLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            bonusLabel.topAnchor.constraint(equalTo: salaryField.bottomAnchor, constant: 32),

            bonusField.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            bonusField.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            bonusField.topAnchor.constraint(equalTo: bonusLabel.bottomAnchor, constant: 4),
            bonusField.heightAnchor.constraint(equalToConstant: 40),
            
            monthlyLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            monthlyLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            monthlyLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),

            monthlyField.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            monthlyField.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            monthlyField.topAnchor.constraint(equalTo: monthlyLabel.bottomAnchor, constant: 4),
            monthlyField.heightAnchor.constraint(equalToConstant: 40),

            monthlyError.topAnchor.constraint(equalTo: monthlyField.bottomAnchor, constant: 4),
            monthlyError.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            monthlyError.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            monthlyInformationImageView.heightAnchor.constraint(equalToConstant: 20),
            monthlyInformationImageView.widthAnchor.constraint(equalToConstant: 20),

            monthlyInfomationalStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            monthlyInfomationalStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            monthlyInfomationalStackView.topAnchor.constraint(equalTo: monthlyField.bottomAnchor, constant: 32)
        ])
        
        if let text = monthlyField.text, text.isEmpty {
            customNavBar.hideRightButton(hide: true)
        }

        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    func bind(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool) {
        loadViewIfNeeded()

        viewModel = SetSalaryViewModel(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
        setupListeners()
        
        setupViews()

        if let salary = incomeData?.salary, !salary.isEmpty {
            salaryField.text = incomeData?.salary
            bonusField.text = incomeData?.bonus
            monthlyField.text = incomeData?.monthly

            showNext = false

            customNavBar.addRightButton(title: "Update") { [weak self] in
                self?.submitButtonHandle()
            }
        } else {
            customNavBar.addRightButton(title: "Next") { [weak self] in
                self?.submitButtonHandle()
                self?.showNext = true
            }
            customNavBar.hideRightButton(hide: true)
        }

        apply(styles: AppStyles.shared)
    }
    
    func setupListeners() {
        viewModel?.$next
            .receive(on: DispatchQueue.main)
            .sink { [weak self] next in
                guard next else { return }
                self?.next()
            }
            .store(in: &subscriptions)
    }
    
    func next() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true) {
                let confirmIncomeCoordinator = ConfirmIncomeCoordinator(presenter: presenter, incomeData: viewModel.incomeData, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                confirmIncomeCoordinator.start()
            }
        }
    }

    private func submitButtonHandle() {
        validate()
        
        if isValid() {
            if let salary = salaryField.text, let bonus = bonusField.text, let monthly = monthlyField.text {
                viewModel?.showIncomeSummary(salary: salary, bonus: bonus, monthly: monthly)
            }
        } else {
            customAlertView = CustomAlertView(style: AppStyles.shared, title: "INCORRECT VALUE", message: "Your Annual Base Salary must be greater than 12x your Monthly Take Home Pay.", rightButtonTitle: "Ok") { [weak self] in
                self?.customAlertView?.removeFromSuperview()
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
    }
    
    private func validate() {
        annualError.isHidden = isValid()
        monthlyError.isHidden = isValid()
    }
    
    private func isValid() -> Bool {
        if fieldsNotEmpty(), let salary = salaryField.text, let monthly = monthlyField.text {
            return monthly.formatAndConvert() * 12 <= salary.formatAndConvert()
        }
        return false
    }
    
    private func fieldsNotEmpty() -> Bool {
        if let salary = salaryField.text, !salary.isEmpty, salary.formatAndConvert() > 0.0, let monthly = monthlyField.text, !monthly.isEmpty, monthly.formatAndConvert() > 0.0 {
            return true
        }
        return false
    }

    private func backButtonHandle() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showNextButon() {
        if showNext, fieldsNotEmpty() {
            showNext = false
            customNavBar.hideRightButton(hide: false)
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        showNextButon()
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }

    @objc func monthlyTextFieldDidChange(_ textField: UITextField) {
        showNextButon()
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
}

extension SetSalaryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hex: "#72F0F0").cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).cgColor
        
        if let monthlyText = monthlyField.text, let salaryText = salaryField.text,
           !monthlyText.isEmpty, !salaryText.isEmpty {
            validate()
        }
    }
}

extension SetSalaryViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
