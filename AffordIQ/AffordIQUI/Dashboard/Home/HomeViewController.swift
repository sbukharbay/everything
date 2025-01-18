//
//  HomeViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 29.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine
import AffordIQNetworkKit

class HomeViewController: FloatingButtonController, Stylable, DashboardBindable, ErrorPresenter {
    private(set) lazy var topBlurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private(set) lazy var bottomBlurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private(set) lazy var infoLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = ""
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var monthsCircleMeterView: CircularMeterView = {
        let meter = CircularMeterView(frame: .zero)
        meter.numberOfSegments = 16
        meter.lineWidth = 6
        meter.isClockwise = true
        return meter
    }()

    private(set) lazy var monthsLabel: DashboardLargeTitle = {
        let label = DashboardLargeTitle()
        label.text = ""
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var untilAffordableLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Months until affordable"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var meterStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [monthsLabel, untilAffordableLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var leisureCircleMeterView: CircularMeterView = {
        let meter = CircularMeterView(frame: .zero)
        meter.numberOfSegments = 16
        meter.lineWidth = 6
        meter.isClockwise = false
        return meter
    }()

    private(set) lazy var leisureTopLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .center
        label.text = "Approx."
        return label
    }()

    private(set) lazy var leisureMidLabel: DashboardLargeLabel = {
        let label = DashboardLargeLabel()
        label.textAlignment = .center
        label.text = ""
        return label
    }()

    private(set) lazy var leisureBottomLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .center
        label.text = "Left to spend this month"
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var leisureStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leisureTopLabel, leisureMidLabel, leisureBottomLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.layer.cornerRadius = 5
        progressBar.layer.masksToBounds = true
        progressBar.trackTintColor = UIColor(white: 1, alpha: 0.3)
        progressBar.progressImage = UIImage(named: "progress_bar", in: uiBundle, compatibleWith: nil)
        progressBar.setProgress(0.5, animated: false)
        return progressBar
    }()

    private(set) lazy var depositLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Deposit"
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var currentDepositLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Current"
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var currentDepositAmountLabel: BodyLabelDarkSemiBold = {
        let label = BodyLabelDarkSemiBold()
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    private(set) lazy var notificationButton: BadgeButton = {
        let button = BadgeButton(frame: .init(origin: .zero, size: CGSize(width: 20, height: 20)))
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.imageView?.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    private(set) lazy var currentDepositStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentDepositLabel, currentDepositAmountLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var currentTargetLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Target"
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var currentTargetAmountLabel: BodyLabelDarkSemiBold = {
        let label = BodyLabelDarkSemiBold()
        label.text = ""
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var currentTargetStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentTargetLabel, currentTargetAmountLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var amountsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentDepositStackView, currentTargetStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    private(set) lazy var depositLeftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [depositLabel, progressBar])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private(set) lazy var depositImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "deposit_goal", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private(set) lazy var depositStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [depositImageView, depositLeftStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: depositImageView)
        return stackView
    }()

    private(set) lazy var propertyLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Property"
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var propertyAmountLabel: BodyLabelDarkSemiBold = {
        let label = BodyLabelDarkSemiBold()
        label.text = ""
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var propertyLeftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [propertyLabel, propertyAmountLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private(set) lazy var propertyImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "property", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private(set) lazy var propertyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [propertyImageView, propertyLeftStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: propertyImageView)
        return stackView
    }()

    private(set) lazy var helpButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hex: "72F0F0")
        button.setBackgroundImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(onHelpButtonTap), for: .touchUpInside)
        return button
    }()

    private(set) lazy var alertView: CustomTopAlertView = .init(title: "Help", icon: UIImage(systemName: "questionmark.circle"), message: alertMessage, buttonTitle: "Ok", buttonAction: {
        self.alertView.removeFromSuperview()
    })

    private var viewModel: HomeViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var alertMessage: NSMutableAttributedString = .init()
    private var subscriptions = Set<AnyCancellable>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
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
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        let height = view.frame.height / 5.5

        NSLayoutConstraint.activate([
            monthsCircleMeterView.heightAnchor.constraint(equalToConstant: height),
            monthsCircleMeterView.widthAnchor.constraint(equalToConstant: height),

            leisureCircleMeterView.heightAnchor.constraint(equalToConstant: height),
            leisureCircleMeterView.widthAnchor.constraint(equalToConstant: height)
        ])
    }

    func resume() {
        viewModel?.resume()
    }

    func bind(styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        viewModel = HomeViewModel()
        
        setupNavBar()

        setupViews()
        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
        setupListeners()
        setupSwipeGesture()
    }
    
    private func setupListeners() {
        NotificationManager.shared.$notificationCounter
            .sink { [weak self] newValue in
                guard let self else { return }
                self.notificationButton.addBadgeToButton(
                    badge: newValue == 0 ? nil : String(newValue)
                )
            }
            .store(in: &subscriptions)
        
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.$updateBottom
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                if let data {
                    self?.updateBottom(data)
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$updateTop
            .receive(on: DispatchQueue.main)
            .sink { [weak self] affordability in
                if let affordability {
                    self?.updateTop(affordability)
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$updateTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                if let update, update {
                    self?.updateTitle()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$reconsent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] renew in
                if renew {
                    self?.reconsent()
                }
            }
            .store(in: &subscriptions)
    }

    func setupViews() {
        [topBlurEffectView, monthsCircleMeterView, meterStackView, depositStackView, amountsStackView, propertyStackView, bottomBlurEffectView, helpButton, infoLabel, leisureCircleMeterView, leisureStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            topBlurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBlurEffectView.bottomAnchor.constraint(equalTo: propertyStackView.bottomAnchor, constant: 24),

            monthsCircleMeterView.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor, constant: 24),
            monthsCircleMeterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            meterStackView.centerXAnchor.constraint(equalTo: monthsCircleMeterView.centerXAnchor),
            meterStackView.centerYAnchor.constraint(equalTo: monthsCircleMeterView.centerYAnchor),
            meterStackView.leadingAnchor.constraint(equalTo: monthsCircleMeterView.leadingAnchor, constant: 8),
            meterStackView.trailingAnchor.constraint(equalTo: monthsCircleMeterView.trailingAnchor, constant: -8),

            depositStackView.topAnchor.constraint(equalTo: monthsCircleMeterView.bottomAnchor, constant: 24),
            depositStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 20),
            depositStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),

            progressBar.heightAnchor.constraint(equalToConstant: 10),

            depositImageView.heightAnchor.constraint(equalToConstant: 34),
            depositImageView.widthAnchor.constraint(equalToConstant: 34),

            amountsStackView.topAnchor.constraint(equalTo: depositStackView.bottomAnchor, constant: 8),
            amountsStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 60),
            amountsStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),

            propertyStackView.topAnchor.constraint(equalTo: amountsStackView.bottomAnchor, constant: 16),
            propertyStackView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 20),
            propertyStackView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),

            propertyImageView.heightAnchor.constraint(equalToConstant: 34),
            propertyImageView.widthAnchor.constraint(equalToConstant: 34),

            bottomBlurEffectView.topAnchor.constraint(equalTo: topBlurEffectView.bottomAnchor, constant: 16),
            bottomBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomBlurEffectView.bottomAnchor.constraint(equalTo: leisureCircleMeterView.bottomAnchor, constant: 16),

            helpButton.topAnchor.constraint(equalTo: bottomBlurEffectView.topAnchor, constant: 16),
            helpButton.trailingAnchor.constraint(equalTo: bottomBlurEffectView.trailingAnchor, constant: -16),
            helpButton.heightAnchor.constraint(equalToConstant: 24),
            helpButton.widthAnchor.constraint(equalToConstant: 24),

            infoLabel.leadingAnchor.constraint(equalTo: leisureCircleMeterView.trailingAnchor, constant: 16),
            infoLabel.centerYAnchor.constraint(equalTo: bottomBlurEffectView.centerYAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: bottomBlurEffectView.trailingAnchor, constant: -16),

            leisureCircleMeterView.leadingAnchor.constraint(equalTo: bottomBlurEffectView.leadingAnchor, constant: 16),
            leisureCircleMeterView.centerYAnchor.constraint(equalTo: bottomBlurEffectView.centerYAnchor),

            leisureStackView.centerXAnchor.constraint(equalTo: leisureCircleMeterView.centerXAnchor),
            leisureStackView.centerYAnchor.constraint(equalTo: leisureCircleMeterView.centerYAnchor),
            leisureStackView.leadingAnchor.constraint(equalTo: leisureCircleMeterView.leadingAnchor, constant: 8),
            leisureStackView.trailingAnchor.constraint(equalTo: leisureCircleMeterView.trailingAnchor, constant: -8)
        ])
    }

    func updateBottom(_ data: HomeModel) {
        infoLabel.text = data.info

        let amount = Float(data.leftToSpend.amount?.floatValue ?? 0)
        let max = amount * 0.75 + amount
        leisureCircleMeterView.progress = Float((max - amount) / max)
        leisureMidLabel.text = data.leftToSpend.amount ?? 0 <= 0 ? "£0" : data.leftToSpend.shortDescription

        if data.isOverSpend {
            leisureBottomLabel.text = "Over budget this month"
            let color = UIColor(hex: "#E6114E")
            leisureMidLabel.textColor = color

            leisureCircleMeterView.isClockwise = true
            leisureCircleMeterView.color1 = color
            leisureCircleMeterView.color2 = color
            leisureCircleMeterView.color3 = color
            leisureCircleMeterView.color4 = color
        } else {
            leisureBottomLabel.text = "Left to spend this month"
            leisureBottomLabel.textColor = .white

            leisureCircleMeterView.isClockwise = false
            leisureCircleMeterView.color1 = UIColor(hex: "#30f2fc")
            leisureCircleMeterView.color2 = UIColor(hex: "#2ec7ce")
            leisureCircleMeterView.color3 = UIColor(hex: "#028e8e")
            leisureCircleMeterView.color4 = UIColor(hex: "#014766")
        }

        alertMessage = data.message
    }

    private func setupNavBar() {
        let leftItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: self, action: #selector(leftButtonHandle))
        leftItem.tintColor = .white
        
        notificationButton.addTarget(self, action: #selector(rightButtonHandle), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: notificationButton)

        navigationItem.setLeftBarButton(leftItem, animated: false)
        navigationItem.setRightBarButton(rightItem, animated: false)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
    }

    func updateTop(_ mortgageLimits: PropertyGoalAndMortgageLimitsResponse) {
        guard let monthsCount = mortgageLimits.monthsUntilAffordable else {
            monthsLabel.text = "?"
            monthsCircleMeterView.progress = 1.0
            return
        }

        let deposit = (1 - (mortgageLimits.depositGoal?.loanToValue ?? 0)) * 100
        progressBar.setProgress(viewModel?.progressBarAmount ?? 1, animated: false)

        let current = mortgageLimits.mortgageLimits?.currentDeposit
        let target = mortgageLimits.targetDeposit

        currentDepositAmountLabel.text = current?.shortDescription ?? "N/A"
        currentTargetAmountLabel.text = target?.shortDescription ?? "N/A"
        depositLabel.text = "Deposit (" + Int(deposit.floatValue).description + "%)"

        propertyAmountLabel.text = mortgageLimits.propertyGoal?.propertyValue?.shortDescription ?? "N/A"

        monthsLabel.text = monthsCount > 36 ? "36+" : monthsCount.description
        
        switch monthsCount {
        case 0:
            monthsLabel.text = "NOW"
            untilAffordableLabel.text = "Affordable"
        case 1:
            untilAffordableLabel.text = "Month until affordable"
        default:
            untilAffordableLabel.text = "Months until affordable"
        }
        
        monthsCircleMeterView.progress = monthsCount >= 48 ? 0 : (48 - Float(monthsCount)) / 48
    }
    
    private func reconsent() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = RenewConsentInformationCoordinator(presenter: presenter, accounts: viewModel.accountsAndConsents)
                coordinator.start()
            })
        }
    }
    
    func updateTitle() {
        navigationItem.title = viewModel?.userName
    }

    @objc func leftButtonHandle() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = DashboardSettingsCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }

    @objc func rightButtonHandle() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = NotificationsCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }

    @objc func onHelpButtonTap() {
        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            alertView.heightAnchor.constraint(equalToConstant: view.frame.height / 1.50)
        ])
    }
}

extension HomeViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let viewModel = viewModel {
            apply(styles: viewModel.styles)
        }
    }
}
