//
//  ExternalCapitalViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 19/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class ExternalCapitalViewController: FloatingButtonController, Stylable, ErrorPresenter {
    @IBOutlet var submitButton: UIButton?
    @IBOutlet var cancelButton: UIButton?

    @IBOutlet var content: UIView?
    @IBOutlet var editingControls: UIView?
    @IBOutlet var targetHeight: NSLayoutConstraint?
    @IBOutlet var fullHeight: NSLayoutConstraint?
    @IBOutlet var bottomConstraintManager: BottomConstraintManager?

    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var capitalDescription: UITextView!
    @IBOutlet var capitalAmount: UITextField?
    @IBOutlet var capitalAmountError: UILabel?
    @IBOutlet var capitalDescriptionError: UILabel?

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Own Your Finances") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()

    var viewModel: ExternalCapitalViewModel?
    var isClosing: Bool = false
    var textFieldHandler: FormTextFieldDelegateImpl<ExternalCapitalViewController>?
    private var subscriptions: Set<AnyCancellable> = []

    func bind(targetHeight: CGFloat?, externalCapital: ExternalCapitalResponse?) {
        loadViewIfNeeded()

        if let targetHeight = targetHeight {
            self.targetHeight?.constant = targetHeight - 40.0
        }

        viewModel = ExternalCapitalViewModel(view: self)

        if let externalCapital {
            viewModel?.isNew = false
            set(description: externalCapital.description)
            set(value: externalCapital.externalCapitalAmount)
        }
        
        setupViews()
        setupListeners()
        clearMessages()
        updateEditingControls(editing: false)

        if let viewModel = viewModel {
            textFieldHandler = FormTextFieldDelegateImpl(form: self, viewModel: viewModel, liveValidation: true)
        }

        apply(styles: AppStyles.shared)

        bringFeedbackButton(String(describing: type(of: self)))
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomConstraintManager?.startMonitoring()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        bottomConstraintManager?.endMonitoring()
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        capitalDescription.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).cgColor
        capitalDescription.layer.borderWidth = 0.5
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])

        navigationController?.isNavigationBarHidden = true
    }

    func setupViews() {
        capitalAmount?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    func updateFirstResponder(editing _: Bool) {
        if !isEditing {
            for field in fields.compactMap({ $0 }).filter({ $0.canResignFirstResponder }) {
                field.resignFirstResponder()
            }
        }
    }

    func updateEditingControls(editing: Bool) {
        editingControls?.isHidden = !editing
    }

    override var isEditing: Bool {
        get {
            return super.isEditing
        }
        set {
            if newValue == super.isEditing {
                return
            }

            super.isEditing = newValue

            if newValue {
                targetHeight?.priority = UILayoutPriority(rawValue: 1.0)
                fullHeight?.priority = UILayoutPriority(rawValue: 650.0)
            } else {
                targetHeight?.priority = UILayoutPriority(rawValue: 999.0)
                fullHeight?.priority = UILayoutPriority(rawValue: 1.0)
            }

            updateEditingControls(editing: newValue)
            updateFirstResponder(editing: newValue)
        }
    }
}

extension ExternalCapitalViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = AppStyles.shared.colors.fields.light.focusedBorder.color.cgColor
        textView.layer.borderWidth = 1
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 50
    }

    func textViewDidChange(_ textView: UITextView) {
        counterLabel.text = (50 - textView.text.count).description
        viewModel?.description = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).cgColor
        textView.layer.borderWidth = 0.5
    }

    @IBAction func submit(_: Any?) {
        submit()
    }

    @IBAction func cancel(_: Any?) {
        isEditing = false
    }
}

extension ExternalCapitalViewController: StoryboardInstantiable {
    static func instantiate() -> Self? {
        return instantiate(storyboard: "Affordability", identifier: "OutsideCapital")
    }
}

extension ExternalCapitalViewController: Form {
    typealias ViewModelType = ExternalCapitalViewModel

    var fields: [UITextField?] {
        [capitalAmount]
    }

    var messages: [UILabel?] {
        [capitalAmountError, capitalDescriptionError]
    }

    var filters: [OutsideCapitalFieldType: (Character) -> Bool] {
        return [.amount: isValidForAmount(_:)]
    }

    var isSubmitEnabled: Bool {
        get {
            return submitButton?.isEnabled ?? false
        }
        set {
            submitButton?.isEnabled = newValue
        }
    }
}

extension ExternalCapitalViewController {
    func isValidForAmount(_ character: Character) -> Bool {
        if character.unicodeScalars.allSatisfy({ CharacterSet.decimalDigits.contains($0) }) {
            return true
        }

        let string = String(character)
        let locale = Locale.autoupdatingCurrent

        if string == locale.decimalSeparator
            || string == locale.groupingSeparator
            || string == locale.currencySymbol {
            return true
        }

        return false
    }
}

extension ExternalCapitalViewController: OutsideCapitalView {
    func set(description: String?) {
        capitalDescription?.text = description

        if let text = description {
            counterLabel.text = (50 - text.count).description
        }
    }

    func set(value: MonetaryAmount) {
        capitalAmount?.text = value.description
    }

    func endEditing(close: Bool) {
        isEditing = false

        if close, let navigationController = navigationController {
            view.isUserInteractionEnabled = false

            asyncAfter(.milliseconds(500)) {
                if let vc = navigationController.viewControllers.last(where: { $0 is DepositViewController }), let deposit = vc as? DepositViewController {
                    deposit.reload()
                    navigationController.popToViewController(deposit, animated: true)
                }
            }
        }
    }
}
