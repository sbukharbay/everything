//
//  SelfEmployedTimeViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 06.12.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls
import AffordIQFoundation
import Combine

class SelfEmployedTimeViewController: FloatingButtonController, Stylable, ErrorPresenter {
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
    
    private let questionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        return label
    }()
    
    private let monthLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Months"
        label.textAlignment = .left
        return label
    }()
    
    private let yearLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Years"
        label.textAlignment = .left
        return label
    }()
    
    private lazy var titlesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [yearLabel, monthLabel])
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        return stackView
    }()
    
    private lazy var yearField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.delegate = self
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(yearPickerDone))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        textField.inputAccessoryView = toolBar
        textField.inputView = yearPickerView
        return textField
    }()
    
    private lazy var monthField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.delegate = self
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(monthPickerDone))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        textField.inputAccessoryView = toolBar
        textField.inputView = monthPickerView
        return textField
    }()
    
    private lazy var fieldsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [yearField, monthField])
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        return stackView
    }()
    
    private lazy var yearPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor(hex: "0F0728")
        picker.tintColor = .white
        return picker
    }()
    
    private lazy var monthPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor(hex: "0F0728")
        picker.tintColor = .white
        return picker
    }()
    
    private let durationError: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Duration must be longer than 0 months"
        label.isHidden = true
        return label
    }()
    
    var viewModel: SelfEmployedTimeViewModel?
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
        [backgroundImageView, blurEffectView, topStackView, questionLabel, titlesStackView, fieldsStackView, durationError, customNavBar].forEach {
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
            blurEffectView.bottomAnchor.constraint(equalTo: fieldsStackView.bottomAnchor, constant: 40),
            
            incomeIcon.heightAnchor.constraint(equalToConstant: 32),
            incomeIcon.widthAnchor.constraint(equalToConstant: 32),
            
            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            topStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            
            questionLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 24),
            questionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            titlesStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 24),
            titlesStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            titlesStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            fieldsStackView.topAnchor.constraint(equalTo: titlesStackView.bottomAnchor, constant: 8),
            fieldsStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            fieldsStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            yearField.heightAnchor.constraint(equalToConstant: 40),
            monthField.heightAnchor.constraint(equalToConstant: 40),
            
            durationError.topAnchor.constraint(equalTo: fieldsStackView.bottomAnchor, constant: 8),
            durationError.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            durationError.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16)
        ])
    }
    
    func bind(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool) {
        loadViewIfNeeded()
        
        viewModel = SelfEmployedTimeViewModel(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
        setupListeners()
        
        setupViews()
        apply(styles: AppStyles.shared)
        
        if let data = incomeData?.selfEmploymentData {
            questionLabel.text = "How long have you been a " + data.type.getText().lowercased() + "?"
        }
        
        if incomeData?.selfEmploymentData?.months == nil {
            customNavBar.addRightButton(title: "Next") { [weak self] in
                self?.nextButtonHandle()
            }
        } else {
            customNavBar.addRightButton(title: "Update") { [weak self] in
                self?.updateButtonHandle()
            }
            
            guard let period = incomeData?.selfEmploymentData?.months else { return }
            let years = period / 12
            let months = period % 12
            
            yearPickerView.selectRow(years, inComponent: 0, animated: false)
            yearField.text = years.description
            viewModel?.selectedYear = years
            
            monthPickerView.selectRow(months, inComponent: 0, animated: false)
            monthField.text = months.description
            viewModel?.selectedMonth = months
        }
        
        customNavBar.hideRightButton(hide: true)
        
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
        
        viewModel?.$update
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard update else { return }
                self?.update()
            }
            .store(in: &subscriptions)
        
        viewModel?.$next
            .receive(on: DispatchQueue.main)
            .sink { [weak self] next in
                guard next else { return }
                self?.next()
            }
            .store(in: &subscriptions)
    }
    
    func update() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let confirmIncomeCoordinator = ConfirmIncomeCoordinator(presenter: presenter, incomeData: viewModel.incomeData, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                confirmIncomeCoordinator.start()
            })
        }
    }
    
    func next() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = SelfEmployedProfitCoordinator(presenter: presenter, incomeData: viewModel.incomeData, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                coordinator.start()
            })
        }
    }
    
    @objc func yearPickerDone() {
        yearField.endEditing(true)
        
        checkRightButton()
    }
    
    @objc func monthPickerDone() {
        monthField.endEditing(true)
        
        checkRightButton()
    }
    
    private func nextButtonHandle() {
        viewModel?.setData()
    }
    
    private func updateButtonHandle() {
        viewModel?.setData()
    }
    
    private func checkRightButton() {
        if let years = yearField.text {
            viewModel?.selectedYear = Int(years)
        }
        if let months = monthField.text {
            viewModel?.selectedMonth = Int(months)
        }
        
        if let vm = viewModel, vm.selectedYear != nil, vm.selectedMonth != nil {
            let durationIsValid = vm.selectedYear == 0 && vm.selectedMonth == 0
            durationError.isHidden = !durationIsValid
            customNavBar.hideRightButton(hide: durationIsValid)
        }
    }
    
    func showImportant() {
        var alertView: FullScreenAlertView!
        alertView = FullScreenAlertView(
            title: "Important",
            icon: UIImage(systemName: "exclamationmark.bubble"),
            message: "Getting a mortgage with less than 1 year of self employment history is very unlikely. We can still continue and estimate what you could afford if your circumstances remained the same after 12 months of being self-employed",
            buttonTitle: "Ok",
            buttonAction: { [weak self] in
                self?.next()
                alertView.removeFromSuperview()
            }
        )
        alertView.style(styles: AppStyles.shared)
        
        guard let alertView else { return }

        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SelfEmployedTimeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == yearPickerView {
            return 91
        }
        return 12
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: row.description, attributes: [.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == yearPickerView {
            yearField.text = row.description
        } else {
            monthField.text = row.description
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32
    }
}

extension SelfEmployedTimeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hex: "#72F0F0").cgColor
        
        if let text = textField.text, text.isEmpty {
            textField.text = "0"
            
            if textField == yearField {
                viewModel?.selectedYear = 0
            } else {
                viewModel?.selectedMonth = 0
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).cgColor
    }
}

extension SelfEmployedTimeViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
