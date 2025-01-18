//
//  SetSavingsGoalViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 24/02/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine
import Amplitude

class SetSavingsGoalViewController: FloatingButtonController, Stylable, ViewController, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Set a Goal", rightButtonTitle: "Set") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: { [weak self] in
            self?.viewModel?.setSavingsGoal(savingsGoal: self?.sliderValue.text ?? "")
        }
        return navBar
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let savingsImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "savings", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private let savingsLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Savings"
        return label
    }()

    private let zeroSurplusLabel: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "You currently don't produce a surplus and therefore can't set a savings goal."
        label.numberOfLines = 0
        return label
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [savingsImageView, savingsLabel])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.setCustomSpacing(12, after: savingsImageView)
        stackView.alignment = .bottom
        return stackView
    }()

    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private lazy var savingsGoalLabel = HeadingLabelDark()

    private let infoLabel: InfoLabel = {
        let label = InfoLabel()
        label.text = "Use the slider to set how much you are going to save each month for buying a home."
        label.numberOfLines = 0
        return label
    }()

    private let buyingLabel: FieldLabelSubheadlineLightBold = {
        let label = FieldLabelSubheadlineLightBold()
        label.text = "Buying a Home"
        return label
    }()

    private lazy var sliderValue = InfoLabel()

    private lazy var buyingLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [buyingLabel, sliderValue])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private let otherLabel: FieldLabelSubheadlineLightBold = {
        let label = FieldLabelSubheadlineLightBold()
        label.text = "Other"
        return label
    }()

    private let remainingSliderValue = InfoLabel()

    private lazy var otherLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [otherLabel, remainingSliderValue])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [buyingLabelStackView, otherLabelStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = UIColor(hex: "#45AEBC")
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()

    private let monthlySurplusLabel: FieldLabelSubheadlineLightBold = {
        let label = FieldLabelSubheadlineLightBold()
        label.text = "Monthly Surplus"
        return label
    }()

    private lazy var monthlySurplusAmount = FieldLabelSubheadlineLight()

    private lazy var monthlySurplusStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [monthlySurplusLabel, monthlySurplusAmount])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    private var viewModel: SetSavingsGoalViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var surplusConstraint: NSLayoutConstraint!
    private var styles: AppStyles?
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

    func bind(styles: AppStyles = AppStyles.shared, isDashboard: Bool) {
        loadViewIfNeeded()

        viewModel = SetSavingsGoalViewModel(isDashboard: isDashboard)

        setupViews()
        setupListeners()
        
        self.styles = styles
        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let error else { return }
                self.present(error: error)
            }
            .store(in: &subscriptions)
        
        // Listener will call func if surplus amount changes
        viewModel?.changeSliderSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedSurplus in
                guard let self else { return }
                self.setSlider(receivedSurplus)
            }
            .store(in: &subscriptions)
        
        // Listener will call func if should setup view
        viewModel?.setupViewsForZeroSurplusSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldSetup in
                guard let self, shouldSetup else { return }
                self.setupViewsForZeroSurplus()
            }
            .store(in: &subscriptions)
        
        // Listener will call func if surplus amount changes
        viewModel?.setSurplusSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldSet in
                guard let self, shouldSet else { return }
                self.setSurplus()
            }
            .store(in: &subscriptions)
    
        // Listener will call func if opertaion complete
        viewModel?.operationCompleteSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] didOperationComplete in
                guard let self, didOperationComplete else { return }
                self.operationComplete()
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    self.showLoadingView(with: "Calculating Data")
                } else {
                    self.hideLoadingView()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$isDone
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isDone in
                guard let self else { return }
                if isDone {
                    self.showLoadingView(with: "Loading...")
                } else {
                    self.hideLoadingView()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func showLoadingView(with message: String) {
        guard let navigationController else { return }
        BusyView.shared.show(
            navigationController: navigationController,
            title: NSLocalizedString(message, bundle: uiBundle, comment: message),
            fullScreen: false
        )
    }
    
    private func hideLoadingView() {
        BusyView.shared.hide()
    }

    func setupViews() {
        [backgroundImageView, blurEffectView, titleStackView, whiteBackgroundView, savingsGoalLabel, infoLabel, slider, monthlySurplusStackView, horizontalStackView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        surplusConstraint = monthlySurplusStackView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 24)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),

            titleStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            titleStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            savingsGoalLabel.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 24),
            savingsGoalLabel.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            whiteBackgroundView.topAnchor.constraint(equalTo: savingsGoalLabel.bottomAnchor, constant: 24),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            infoLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 32),
            infoLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16),

            horizontalStackView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 24),
            horizontalStackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
            horizontalStackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16),

            slider.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: 16),
            slider.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16),

            surplusConstraint,
            monthlySurplusStackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
            monthlySurplusStackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16)
        ])
    }

    func setupViewsForZeroSurplus() {
//        customNavBar.rightButton(isEnabled: false)

        [zeroSurplusLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        slider.isUserInteractionEnabled = false
        savingsGoalLabel.text = "£0/m"
        sliderValue.text = "£0"
        remainingSliderValue.text = "£0"
        monthlySurplusAmount.text = "£0"

        NSLayoutConstraint.deactivate([
            surplusConstraint
        ])

        NSLayoutConstraint.activate([
            zeroSurplusLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 24),
            zeroSurplusLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
            zeroSurplusLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16),

            monthlySurplusStackView.topAnchor.constraint(equalTo: zeroSurplusLabel.bottomAnchor, constant: 24)
        ])
    }

    @objc private func sliderValueChanged(_: UISlider) {
        setRemainingAmount()
    }

    func setRemainingAmount() {
        let newValue = roundSliderValue()
        let value = MonetaryAmount(amount: Decimal(newValue))
        
        savingsGoalLabel.text = "\(value.shortDescription)/m"
        sliderValue.text = value.shortDescription

        guard let monetaryToDecimal = viewModel?.surplus?.amount else { return }

        let remaining = monetaryToDecimal - MonetaryAmount(amount: Decimal(newValue))
        remainingSliderValue.text = remaining.shortDescription
    }
    
    func roundSliderValue() -> Int {
        let newValue: Int
        if Int(slider.value) % 5 > 2 {
            newValue = Int(slider.value) + (5 - (Int(slider.value) % 5))
        } else if Int(slider.value) == 0 {
            newValue = 0
        } else if slider.value == slider.maximumValue {
            newValue = Int(slider.maximumValue)
        } else {
            newValue = Int(slider.value) - (5 - (Int(slider.value) % 5))
        }
        
        return newValue
    }

    func setSurplus() {
        monthlySurplusAmount.text = viewModel?.surplus?.shortDescription ?? "£0"
    }

    func setSlider(_ value: Float) {
        guard let monetaryToFloat = viewModel?.surplus?.amount?.floatValue else {
            print("surplus error return setSlider")
            return }

        slider.minimumValue = 0
        slider.maximumValue = monetaryToFloat > 0 ? monetaryToFloat : 0
        slider.setValue(value, animated: false)

        setRemainingAmount()
    }
    
    func operationComplete() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                presenter.dismiss(animated: true) {
                    if viewModel.isDashboard {
                        presenter.popViewController(animated: true)
                    } else {
                        Amplitude.instance().logEvent(OnboardingStep.setSavingsGoal.rawValue)
                        
                        let coordinator = SetAGoalCheckPointCoordinator(presenter: presenter, type: .savingGoal)
                        coordinator.start()
                    }
                }
            }
        })
    }
}

extension SetSavingsGoalViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
