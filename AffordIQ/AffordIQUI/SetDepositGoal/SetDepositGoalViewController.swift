//
//  SetDepositGoalViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 11/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine
import Amplitude

class SetDepositGoalViewController: FloatingButtonController, Stylable, ViewController, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let navBar = CustomNavigationBar(title: "Set a Goal", rightButtonTitle: "Set") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: { [weak self] in
            Task {
                await self?.viewModel?.setDepositGoal()
            }
        }
        return navBar
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private lazy var depositImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "deposit_goal", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private lazy var depositHeaderLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Deposit"
        return label
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [depositImageView, depositHeaderLabel])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.setCustomSpacing(12, after: depositImageView)
        stackView.alignment = .bottom
        return stackView
    }()

    private lazy var circleMeterView: CircularMeterView = {
        let meter = CircularMeterView(frame: .zero)
        meter.numberOfSegments = 16
        meter.lineWidth = 6
        meter.isClockwise = true
        return meter
    }()

    private lazy var monthsLabel: DashboardLargeLabel = {
        let label = DashboardLargeLabel()
        label.textAlignment = .center
        return label
    }()

    private lazy var untilAffordableLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Months until affordable"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var meterStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [monthsLabel, untilAffordableLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.layer.cornerRadius = 5
        progressBar.layer.masksToBounds = true
        progressBar.trackTintColor = UIColor(white: 1, alpha: 0.3)
        progressBar.progressImage = UIImage(named: "progress_bar", in: uiBundle, compatibleWith: nil)
        progressBar.setProgress(0.5, animated: true)
        return progressBar
    }()

    private lazy var currentDepositLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Current Deposit"
        label.textAlignment = .left
        return label
    }()

    private lazy var currentDepositAmountLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .left
        return label
    }()

    private lazy var currentDepositStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentDepositLabel, currentDepositAmountLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var currentTargetLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .right
        return label
    }()

    private lazy var currentTargetAmountLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .right
        return label
    }()

    private lazy var currentTargetStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentTargetLabel, currentTargetAmountLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var whiteBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private lazy var infoLabel: InfoLabel = {
        let label = InfoLabel()
        label.text = "Use the slider below to set the size of your deposit."
        label.numberOfLines = 0
        return label
    }()

    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = UIColor(hex: "#45AEBC")
        slider.minimumValue = 5
        slider.maximumValue = 40
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()

    private lazy var depositLabel: FieldLabelSubheadlineLightBold = {
        let label = FieldLabelSubheadlineLightBold()
        label.text = "Deposit"
        label.textAlignment = .left
        return label
    }()

    private lazy var sliderValueLabel = FieldLabelSubheadlineLight()

    private lazy var sliderMaxLabel: FieldLabelSubheadlineLight = {
        let label = FieldLabelSubheadlineLight()
        label.textAlignment = .right
        return label
    }()

    var viewModel: SetDepositViewModel?
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

    func bind(isDashboard: Bool, styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        viewModel = SetDepositViewModel(isDashboard: isDashboard)

        setupViews()
        setupListeners()
        
        self.styles = styles
        apply(styles: styles)

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
        
        viewModel?.updateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willUpdate in
                guard willUpdate else { return }
                self?.update()
            }
            .store(in: &subscriptions)
        
        viewModel?.setSliderSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willSetSlider in
                guard willSetSlider else { return }
                self?.setSlider()
            }
            .store(in: &subscriptions)
        
        viewModel?.operationCompleteSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] didComplete in
                guard didComplete else { return }
                self?.operationComplete()
            }
            .store(in: &subscriptions)
        
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let navigationController = self?.navigationController else { return }
                if isLoading {
                    BusyView.shared.show(
                        navigationController: navigationController,
                        title: NSLocalizedString("Calculating Data", bundle: uiBundle, comment: "Calculating Data"),
                        fullScreen: false
                    )
                } else {
                    BusyView.shared.hide(success: true)
                }
            }
            .store(in: &subscriptions)
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let step: Float = 5
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue

        viewModel?.loanToValueData = slider.value

        updateDisplay()
    }

    func updateDisplay() {
        sliderValueLabel.text = "\(String(describing: Int(slider.value)))%"
        currentTargetLabel.text = "Target \(String(describing: Int(slider.value)))%"

        switch Int(slider.value) {
        case 5:
            update(0)
        case 10:
            update(1)
        case 15:
            update(2)
        case 20:
            update(3)
        case 25:
            update(4)
        case 30:
            update(5)
        case 35:
            update(6)
        case 40:
            update(7)
        default:
            break
        }
    }

    func update(_ index: Int) {
        guard let data = viewModel?.affordabilityData else { return }
        guard let currentDeposit = viewModel?.currentDeposit else { return }
        let monthsUntilAffordable = data[index].monthsUntilAffordable ?? 0

        monthsLabel.text = monthsUntilAffordable > 36 ? "36+" : String(describing: monthsUntilAffordable)
        
        switch monthsUntilAffordable {
        case 0:
            monthsLabel.text = "NOW"
            untilAffordableLabel.text = "Affordable"
        case 1:
            untilAffordableLabel.text = "Month until affordable"
        default:
            untilAffordableLabel.text = "Months until affordable"
        }
        
        circleMeterView.progress = monthsUntilAffordable >= 48 ? 0 : (48 - Float(monthsUntilAffordable)) / 48
        sliderMaxLabel.text = data[index].targetDeposit.shortDescription
        currentTargetAmountLabel.text = data[index].targetDeposit.shortDescription
        percentageProgress(currentDeposit, data[index].targetDeposit)
    }

    func percentageProgress(_ currentDeposit: MonetaryAmount, _ targetDeposit: MonetaryAmount) {
        let currentDeposit = currentDeposit
        let targetDeposit = targetDeposit

        let result = Float(truncating: currentDeposit.amount! as NSNumber) / Float(truncating: targetDeposit.amount! as NSNumber)
        progressBar.setProgress(Float(result), animated: false)
    }

    func update() {
        currentDepositAmountLabel.text = viewModel?.currentDeposit?.shortDescription
    }

    func setSlider() {
        guard let vm = viewModel else { return }

        slider.setValue(vm.loanToValueData, animated: false)
        updateDisplay()
    }

    func setupViews() {
        [backgroundImageView, blurEffectView, titleStackView, circleMeterView, meterStackView,
         currentDepositStackView, currentTargetStackView, whiteBackgroundView, infoLabel,
         progressBar, slider, depositLabel, sliderValueLabel, sliderMaxLabel, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

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

            circleMeterView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 24),
            circleMeterView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            circleMeterView.heightAnchor.constraint(equalToConstant: 150),
            circleMeterView.widthAnchor.constraint(equalToConstant: 150),

            whiteBackgroundView.topAnchor.constraint(equalTo: currentDepositStackView.bottomAnchor, constant: 24),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            meterStackView.centerXAnchor.constraint(equalTo: circleMeterView.centerXAnchor),
            meterStackView.centerYAnchor.constraint(equalTo: circleMeterView.centerYAnchor),
            meterStackView.leadingAnchor.constraint(equalTo: circleMeterView.leadingAnchor, constant: 8),
            meterStackView.trailingAnchor.constraint(equalTo: circleMeterView.trailingAnchor, constant: -8),

            progressBar.topAnchor.constraint(equalTo: circleMeterView.bottomAnchor, constant: 24),
            progressBar.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 24),
            progressBar.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),
            progressBar.heightAnchor.constraint(equalToConstant: 10),

            currentDepositStackView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 16),
            currentDepositStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 24),

            currentTargetStackView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 16),
            currentTargetStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),

            infoLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 32),
            infoLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16),

            depositLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            depositLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),

            sliderValueLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            sliderValueLabel.leadingAnchor.constraint(equalTo: depositLabel.trailingAnchor, constant: 16),

            sliderMaxLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            sliderMaxLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16),

            slider.topAnchor.constraint(equalTo: depositLabel.bottomAnchor, constant: 16),
            slider.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16)
        ])
    }
    
    func operationComplete() {
        perform(action: { _ in
            if let presenter = navigationController, let viewModel {
                presenter.dismiss(animated: true, completion: {
                    if viewModel.isDashboard {
                        presenter.popViewController(animated: true)
                    } else {
                        Amplitude.instance().logEvent(OnboardingStep.setDepositGoal.rawValue)
                        
                        let coordinator = SetAGoalCheckPointCoordinator(presenter: presenter, type: .deposit)
                        coordinator.start()
                    }
                })
            }
        })
    }
}

extension SetDepositGoalViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
