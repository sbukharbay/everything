//
//  SelfEmployedProfitViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 08.12.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls
import AffordIQFoundation
import Combine

class SelfEmployedProfitViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = BackgroundImageView(frame: .zero)
    
    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Own Your Finances") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        return view
    }()
    
    private let incomeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "income", in: uiBundle, with: nil)
        return imageView
    }()
    
    private let incomeTitle: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Income"
        return label
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incomeIcon, incomeTitle])
        stackView.distribution = .fill
        stackView.setCustomSpacing(12, after: incomeIcon)
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        return stackView
    }()
    
    private let beforeTaxQuestionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var beforeTaxProfitField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.placeholder = "£"
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private let beforeTaxError: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Consider Revising"
        label.isHidden = true
        return label
    }()
    
    private let infoLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#72F0F0")
        imageView.image = UIImage(systemName: "info.circle")
        return imageView
    }()

    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoIcon, infoLabel])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 8
        stack.alignment = .top
        stack.isHidden = true
        return stack
    }()
    
    private let afterTaxQuestionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var afterTaxProfitField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.placeholder = "£"
        textField.addTarget(self, action: #selector(atpTextFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private let afterTaxError: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Consider Revising"
        label.isHidden = true
        return label
    }()
    
    var viewModel: SelfEmployedProfitViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = ContentSizeMonitor()
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
        [backgroundImageView, blurEffectView, topStackView, beforeTaxQuestionLabel, beforeTaxProfitField, beforeTaxError, infoStackView, afterTaxQuestionLabel, afterTaxProfitField, afterTaxError, customNavBar].forEach {
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
            blurEffectView.bottomAnchor.constraint(equalTo: afterTaxProfitField.bottomAnchor, constant: 32),
            
            incomeIcon.heightAnchor.constraint(equalToConstant: 32),
            incomeIcon.widthAnchor.constraint(equalToConstant: 32),
            
            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            topStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            
            beforeTaxQuestionLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 24),
            beforeTaxQuestionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            beforeTaxQuestionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            beforeTaxProfitField.topAnchor.constraint(equalTo: beforeTaxQuestionLabel.bottomAnchor, constant: 16),
            beforeTaxProfitField.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            beforeTaxProfitField.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            beforeTaxProfitField.heightAnchor.constraint(equalToConstant: 40),
            
            beforeTaxError.topAnchor.constraint(equalTo: beforeTaxProfitField.bottomAnchor, constant: 4),
            beforeTaxError.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            beforeTaxError.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            infoStackView.topAnchor.constraint(equalTo: beforeTaxError.bottomAnchor, constant: 8),
            infoStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            infoIcon.heightAnchor.constraint(equalToConstant: 24),
            infoIcon.widthAnchor.constraint(equalToConstant: 24),
            
            afterTaxQuestionLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 24),
            afterTaxQuestionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            afterTaxQuestionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            afterTaxProfitField.topAnchor.constraint(equalTo: afterTaxQuestionLabel.bottomAnchor, constant: 16),
            afterTaxProfitField.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            afterTaxProfitField.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            afterTaxProfitField.heightAnchor.constraint(equalToConstant: 40),
            
            afterTaxError.topAnchor.constraint(equalTo: afterTaxProfitField.bottomAnchor, constant: 4),
            afterTaxError.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            afterTaxError.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16)
        ])
    }
    
    func bind(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool) {
        loadViewIfNeeded()
        
        viewModel = SelfEmployedProfitViewModel(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
        setupListeners()
        
        setupViews()
        apply(styles: AppStyles.shared)
        
        bringFeedbackButton(String(describing: type(of: self)))
        
        if let months = incomeData?.selfEmploymentData?.months, months < 24 {
            beforeTaxQuestionLabel.text = "In the last year, what were your profits before tax?"
            infoLabel.text = "Generally lenders require you to have been trading for 2 years or more before offering a mortgage. It is still possible to get a mortgage offer with 1 year of trading history but your options will be limited."
            infoStackView.isHidden = false
            afterTaxQuestionLabel.text = "In the last year, how much did you earn after tax?"
            
            if incomeData?.selfEmploymentData?.profitBT != nil, incomeData?.selfEmploymentData?.profitAT != nil {
                beforeTaxProfitField.text = incomeData?.selfEmploymentData?.profitBT?.longDescription
                afterTaxProfitField.text = incomeData?.selfEmploymentData?.profitAT?.longDescription
                
                customNavBar.addRightButton(title: "Update") { [weak self] in
                    self?.nextButtonHandle()
                }
            } else {
                customNavBar.addRightButton(title: "Next") { [weak self] in
                    self?.nextButtonHandle()
                }
            }
        } else {
            beforeTaxQuestionLabel.text = "Over the last 2 years, what were your total profits before tax?"
            afterTaxQuestionLabel.text = "Over the last 2 years, how much did you earn after tax?"
            
            if incomeData?.selfEmploymentData?.incomeBT != nil, incomeData?.selfEmploymentData?.incomeAT != nil {
                beforeTaxProfitField.text = incomeData?.selfEmploymentData?.incomeBT?.longDescription
                afterTaxProfitField.text = incomeData?.selfEmploymentData?.incomeAT?.longDescription
                
                customNavBar.addRightButton(title: "Update") { [weak self] in
                    self?.nextButtonHandle()
                }
            } else {
                customNavBar.addRightButton(title: "Next") { [weak self] in
                    self?.nextButtonHandle()
                }
            }
        }
        
        customNavBar.hideRightButton(hide: true)
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
                let confirmIncomeCoordinator = SelfEmployedInformationCoordinator(presenter: presenter, incomeData: viewModel.incomeData, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                confirmIncomeCoordinator.start()
            }
        }
    }
    
    private func nextButtonHandle() {
        if let btp = beforeTaxProfitField.text, let atp = afterTaxProfitField.text {
            viewModel?.next(btp, atp)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        showNextButon()
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
        
        validateErrorMessages()
    }
    
    @objc func atpTextFieldDidChange(_ textField: UITextField) {
        showNextButon()
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
        
        validateErrorMessages()
    }
    
    private func validateErrorMessages() {
        if !beforeTaxError.isHidden {
            beforeTaxError.isHidden = isValidBTP()
        }
        
        if !afterTaxError.isHidden {
            afterTaxError.isHidden = isValidATP()
        }
    }
    
    private func showNextButon() {
        if isValidBTP(), isValidATP() {
            customNavBar.hideRightButton(hide: false)
        } else {
            customNavBar.hideRightButton(hide: true)
        }
    }
    
    private func isValidBTP() -> Bool {
        if let btp = beforeTaxProfitField.text, btp.count >= 7 {
            return true
        }
        return false
    }
    
    private func isValidATP() -> Bool {
        if let atp = afterTaxProfitField.text, atp.count >= 7 {
            if let btp = beforeTaxProfitField.text, btp.formatAndConvert() >= atp.formatAndConvert() {
                return true
            }
            return false
        }
        return false
    }
}

extension SelfEmployedProfitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 13
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        return newString.count <= maxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hex: "#72F0F0").cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).cgColor
        
        if textField == beforeTaxProfitField {
            beforeTaxError.isHidden = isValidBTP()
            
            if let text = afterTaxProfitField.text, !text.isEmpty {
                afterTaxError.isHidden = isValidATP()
            }
        } else {
            afterTaxError.isHidden = isValidATP()
        }
    }
}

extension SelfEmployedProfitViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
