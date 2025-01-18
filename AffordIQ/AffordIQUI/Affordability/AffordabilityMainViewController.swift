//
//  AffordabilityMainViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 14.02.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class AffordabilityMainViewController: FloatingButtonController, Stylable {
    private(set) lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private(set) lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let navBar = CustomNavigationBar(title: "Own Your Future", rightButtonTitle: "Next") {
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: {
            self?.nextButtonHandle()
        }
        return navBar
    }()

    private(set) lazy var topBlurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private(set) lazy var bottomBlurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private(set) lazy var headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Affordability"
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var buyLabel: HeadlineLabelDark = {
        let label = HeadlineLabelDark()
        label.text = "If I Buy In"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var affordLabel: HeadlineLabelDark = {
        let label = HeadlineLabelDark()
        label.text = "I Can Afford"
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var monthLabel: HeadingLabelDark = {
        let label = HeadingLabelDark()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var helpButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hex: "72F0F0")
        button.setBackgroundImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(onHelpButtonTap), for: .touchUpInside)
        return button
    }()

    private(set) lazy var infoButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hex: "72F0F0")
        button.setBackgroundImage(UIImage(systemName: "info.circle"), for: .normal)
        button.addTarget(self, action: #selector(onInfoButtonTap), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private(set) lazy var titleIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "affordability", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "72F0F0")
        return imageView
    }()

    private(set) lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleIconImage, headerLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .bottom
        stackView.setCustomSpacing(8, after: titleIconImage)
        return stackView
    }()

    private(set) lazy var circularMeterView: CircularMeterView = {
        let view = CircularMeterView(frame: .zero)
        view.numberOfSegments = 16
        view.lineWidth = 4
        view.isClockwise = true
        return view
    }()

    private(set) lazy var topBlurStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, buyLabel, circularMeterView])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()

    private(set) lazy var affordTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(AffordabilityMainAffordTableViewCell.self, forCellReuseIdentifier: AffordabilityMainAffordTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0
        return tableView
    }()

    private(set) lazy var monthsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(AffordabilityMonthsCollectionViewCell.self, forCellWithReuseIdentifier: "AffordabilityMonths")
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()

    private(set) lazy var percentagePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor(hex: "0F0728")
        picker.tintColor = .white
        return picker
    }()

    private(set) lazy var percentageToolbar: UIToolbar = {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(percentageDone))
        doneButton.tintColor = UIColor(hex: "72F0F0")

        var titleLabel = UIBarButtonItem(title: "Deposit", style: .done, target: self, action: nil)
        titleLabel.tintColor = .white

        let toolBar = UIToolbar(frame: .zero)
        toolBar.backgroundColor = UIColor(hex: "0F0728")

        let emptySpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([emptySpace, emptySpace, emptySpace, emptySpace, emptySpace, titleLabel, emptySpace, emptySpace, emptySpace, doneButton], animated: true)
        return toolBar
    }()

    private(set) lazy var percentagePickerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [percentageToolbar, percentagePickerView])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.isHidden = true
        return stackView
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
    
    private(set) lazy var overlayView: TableOverlayView = {
        let view = TableOverlayView(frame: .zero)
        view.tabVisible = true
        view.heading = nil
        view.title = nil
        view.delegate = self
        return view
    }()

    private(set) lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()

    private var alertView: CustomTopAlertView!
    private var zeroAffordabilityAlertView: CustomTopAlertView!
    private var openConstraint: NSLayoutConstraint?
    private var viewModel: AffordabilityMainViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    private var styles: AppStyles?
    private var affordabilityStyling: AffordabilityStyling?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let presenter = navigationController,
           let vm = viewModel,
           vm.affordabilityCalculations.isEmpty,
           let styles {
            BusyView.shared.show(
                navigationController: presenter,
                title: NSLocalizedString("Calculating Data", bundle: uiBundle, comment: "Calculating Data"),
                subtitle: NSLocalizedString("", bundle: uiBundle, comment: ""),
                styles: styles,
                fullScreen: false
            )
        }

        if let vm = viewModel {
            switch vm.viewType {
            case .dashboard:
                navigationController?.isNavigationBarHidden = true
            case .tabbar:
                navigationController?.isNavigationBarHidden = false
                navigationController?.tabBarController?.tabBar.isHidden = false
            default:
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        contentSizeMonitor.removeObserver()

        if let vm = viewModel {
            switch vm.viewType {
            case .tabbar:
                navigationController?.isNavigationBarHidden = true
            default:
                break
            }
        }
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom)
        ])

        switch viewModel?.viewType {
        case .tabbar:
            backgroundImageView.isHidden = true
            NSLayoutConstraint.activate([
                customNavBar.heightAnchor.constraint(equalToConstant: 0),

                topBlurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
            ])
        default:
            backgroundImageView.isHidden = false
            NSLayoutConstraint.activate([
                backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                topBlurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),

                customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
            ])
        }
    }

    @objc private func tapToDismiss(_: UITapGestureRecognizer) {
        if openConstraint?.priority == .required {
            overlayView.close()
        }
    }
}

extension AffordabilityMainViewController: ErrorPresenter {
    func updateData(_ row: Int) {
        monthsCollectionView.reloadData()
        affordTableView.reloadData()

        percentagePickerView.reloadAllComponents()
        percentagePickerView.selectRow(row, inComponent: 0, animated: false)

        overlayView.tableView?.reloadData()
    }

    func setMonths(_ monthsCount: Int) {
        guard let affordabilityStyling else { return }
        let timeUntilAffordable = affordabilityDescription(
            monthsUntilAffordable: monthsCount,
            styles: affordabilityStyling
        )
        monthLabel.attributedText = timeUntilAffordable
        circularMeterView.progress = monthsCount >= 48 ? 0 : (48 - Float(monthsCount)) / 48

        switch viewModel?.viewType {
        case .tabbar:
            if monthsCount == 0 {
                navigationItem.title = "If I Buy"
                buyLabel.removeFromSuperview()
                titleStackView.removeFromSuperview()
            } else {
                navigationItem.title = "If I Buy In"
                buyLabel.removeFromSuperview()
                titleStackView.removeFromSuperview()
            }
        default:
            break
        }
    }

    func zeroAffordabilityAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            view.addSubview(zeroAffordabilityAlertView)
            zeroAffordabilityAlertView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                zeroAffordabilityAlertView.topAnchor.constraint(equalTo: view.topAnchor),
                zeroAffordabilityAlertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                zeroAffordabilityAlertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                zeroAffordabilityAlertView.heightAnchor.constraint(equalToConstant: view.frame.height / 2)
            ])
        }
        customNavBar.hideRightButton(hide: true)
    }

    @objc func percentageDone() {
        percentagePickerStackView.isHidden = true
        if let vm = viewModel {
            switch vm.viewType {
            case .tabbar:
                navigationController?.tabBarController?.tabBar.isHidden = false
            default:
                break
            }
        }
    }

    func createDataSource(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.register(AffordabilityMainOverlayTableViewCell.self, forCellReuseIdentifier: AffordabilityMainOverlayTableViewCell.reuseIdentifier)
        tableView.register(AffordabilityMainOverlayHeaderView.self, forHeaderFooterViewReuseIdentifier: AffordabilityMainOverlayHeaderView.reuseIdentifier)
        tableView.register(AffordabilityMainOverlayFooterView.self, forHeaderFooterViewReuseIdentifier: AffordabilityMainOverlayFooterView.reuseIdentifier)
        tableView.sectionHeaderHeight = 0
    }
}

extension AffordabilityMainViewController {
    func bind(
        type: AffordabilityMainViewType,
        getStartedType: GetStartedViewType?,
        styles: AppStyles = AppStyles.shared,
        isDashboard: Bool
    ) {
        setupAlerts(styles)

        viewModel = AffordabilityMainViewModel(type: type, getStartedType: getStartedType, isDashboard: isDashboard)
        setupViews()
        setupListeners()
        
        setAffordabilityStyle(styles)
        apply(styles: styles)
        self.styles = styles

        topBlurEffectView.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true

        if let tableView = overlayView.tableView {
            createDataSource(tableView: tableView)
        }

        setByType(type)
        
        if type == .tabbar {
            setupSwipeGesture()
        }
    }

    func setupAlerts(_ styles: AppStyles) {
        alertView = CustomTopAlertView(
            title: "Help",
            icon: UIImage(systemName: "questionmark.circle"),
            message: NSMutableAttributedString()
                .style("Use the NOW, 3, 6, 9...etc, buttons to see what you can afford now and in the future. You can adjust your deposit to see how it affects your affordability and repayments.",
                       font: styles.fonts.sansSerif.subheadline.regular)
                .style("\n\nBased on what you can afford, choose when you want to buy.",
                       font: styles.fonts.sansSerif.subheadline.regular),
            buttonTitle: "Ok",
            buttonAction: { [weak self] in
                self?.alertView?.removeFromSuperview()
            }
        )
        alertView?.style(styles: styles)

        zeroAffordabilityAlertView = CustomTopAlertView(
            title: "Sorry",
            icon: UIImage(systemName: "hand.thumbsdown"),
            message: NSMutableAttributedString()
                .style("It looks like you cannot afford a mortgage right now. Please review the information you have given us.",
                       font: styles.fonts.sansSerif.subheadline.regular),
            buttonTitle: "Ok",
            buttonAction: { [weak self] in
                self?.zeroAffordabilityAlertView?.removeFromSuperview()
            }
        )
        zeroAffordabilityAlertView?.style(styles: styles)
    }
    
    private func setAffordabilityStyle(_ styles: AppStyles) {
        affordabilityStyling = AffordabilityStyling(
            now: styles.fonts.sansSerif.largeTitle.black,
            month: styles.fonts.sansSerif.largeTitle.black,
            legend: styles.fonts.sansSerif.headline.black,
            foregroundColor: styles.colors.text.fieldDark.color,
            paragraphStyle: nil
        )
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
        
        // Listen to month count update
        viewModel?.monthSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                guard let self else { return }
                self.setMonths(count)
            }
            .store(in: &subscriptions)
        
        // Listen to update view
        viewModel?.updateData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] percentage in
                guard let self else { return }
                self.updateData(percentage)
            }
            .store(in: &subscriptions)
        
        // Listen to show alert
        viewModel?.$zeroAffordabilityAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                guard let self, let show, show else { return }
                self.zeroAffordabilityAlert()
            }
            .store(in: &subscriptions)
        
        // Listen to show property parameters
        viewModel?.$calculation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] calculation in
                guard let self, let calculation else { return }
                self.navigateToPropertySearch(calculation)
            }
            .store(in: &subscriptions)
        
        // Listen to show property search results
        viewModel?.$filters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] params in
                guard let self, let params, let search = params.0 else { return }
                self.navigateToSearchResults(search, params.1)
            }
            .store(in: &subscriptions)
        
        viewModel?.$isDone
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isDone in
                guard let self,
                      self.viewModel?.viewType == .setGoal,
                      self.viewModel?.viewType == .dashboard else {
                    return
                }
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
    
    func navigateToPropertySearch(_ calculation: MonthlyCalculations) {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = PropertyParametersCoordinator(presenter: presenter, homeValue: calculation.homeValue.amount ?? 0, months: viewModel.chosenMonth, isDashboard: viewModel.isDashboard)
                coordinator.start()
            })
        }
    }
    
    func navigateToSearchResults(_ search: ChosenPropertyParameters, _ mortgageLimits: MortgageLimits?) {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = PropertyResultsCoordinator(presenter: presenter, search: search, mortgageLimits: mortgageLimits, months: viewModel.chosenMonth, isDashboard: viewModel.isDashboard)
                coordinator.start()
            })
        }
    }

    func prepareView() {
        affordLabel.isHidden = true
        affordTableView.topAnchor.constraint(equalTo: bottomBlurEffectView.topAnchor, constant: 16).isActive = true
        buyLabel.text = "When do you want to buy?"
        customNavBar.setTitle(text: "Set a Goal")
        customNavBar.renameRightButtonTitle(text: "Apply")
    }

    func setByType(_ type: AffordabilityMainViewType) {
        switch type {
        case .setGoal, .dashboard:
            prepareView()
            titleIconImage.image = UIImage(systemName: "house.fill")
            headerLabel.text = "Property"
        case .filter:
            prepareView()
            titleIconImage.image = UIImage(systemName: "clock")
            headerLabel.text = "When"
        case .tabbar:
            customNavBar.isHidden = true
            infoButton.isHidden = false
            affordTableView.topAnchor.constraint(equalTo: affordLabel.bottomAnchor, constant: 16).isActive = true

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
    }

    func setupViews() {
        [backgroundImageView, topBlurEffectView, topBlurStackView, monthLabel, helpButton, monthsCollectionView, bottomBlurEffectView, affordLabel, affordTableView, infoButton, overlayView, percentagePickerStackView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        switch viewModel?.viewType {
        case .tabbar:
            openConstraint = overlayView.topAnchor.constraint(equalTo: helpButton.bottomAnchor)
            openConstraint?.priority = UILayoutPriority(1.0)
            openConstraint?.isActive = true
        default:
            openConstraint = overlayView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: -8)
            openConstraint?.priority = UILayoutPriority(1.0)
            openConstraint?.isActive = true
        }

        setupConstraints()

        switch viewModel?.viewType {
        case .tabbar:
            let height = view.frame.height / 5.5
            circularMeterView.lineWidth = 6
            NSLayoutConstraint.activate([
                circularMeterView.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor, constant: 24),
                circularMeterView.heightAnchor.constraint(equalToConstant: height),
                circularMeterView.widthAnchor.constraint(equalToConstant: height)
            ])
        default:
            NSLayoutConstraint.activate([
                circularMeterView.heightAnchor.constraint(equalToConstant: 120),
                circularMeterView.widthAnchor.constraint(equalToConstant: 120)
            ])
        }

        bringFeedbackButton(String(describing: type(of: self)))
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            topBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBlurEffectView.bottomAnchor.constraint(equalTo: monthsCollectionView.bottomAnchor, constant: 16),

            topBlurStackView.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor, constant: 16),
            topBlurStackView.centerXAnchor.constraint(equalTo: topBlurEffectView.centerXAnchor),

            titleIconImage.heightAnchor.constraint(equalToConstant: 32),
            titleIconImage.widthAnchor.constraint(equalToConstant: 32),

            monthLabel.centerYAnchor.constraint(equalTo: circularMeterView.centerYAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: circularMeterView.centerXAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: circularMeterView.leadingAnchor, constant: 8),
            monthLabel.trailingAnchor.constraint(equalTo: circularMeterView.trailingAnchor, constant: -8),

            helpButton.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),
            helpButton.topAnchor.constraint(equalTo: topBlurEffectView.topAnchor, constant: 16),
            helpButton.heightAnchor.constraint(equalToConstant: 24),
            helpButton.widthAnchor.constraint(equalToConstant: 24),

            infoButton.trailingAnchor.constraint(equalTo: bottomBlurEffectView.trailingAnchor, constant: -16),
            infoButton.topAnchor.constraint(equalTo: bottomBlurEffectView.topAnchor, constant: 8),
            infoButton.heightAnchor.constraint(equalToConstant: 24),
            infoButton.widthAnchor.constraint(equalToConstant: 24),

            monthsCollectionView.topAnchor.constraint(equalTo: topBlurStackView.bottomAnchor, constant: 16),
            monthsCollectionView.leadingAnchor.constraint(equalTo: topBlurEffectView.leadingAnchor, constant: 16),
            monthsCollectionView.trailingAnchor.constraint(equalTo: topBlurEffectView.trailingAnchor, constant: -16),
            monthsCollectionView.heightAnchor.constraint(equalToConstant: 56),

            bottomBlurEffectView.topAnchor.constraint(equalTo: topBlurEffectView.bottomAnchor, constant: 24),
            bottomBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomBlurEffectView.bottomAnchor.constraint(equalTo: affordTableView.bottomAnchor, constant: 16),

            affordLabel.topAnchor.constraint(equalTo: bottomBlurEffectView.topAnchor, constant: 12),
            affordLabel.leadingAnchor.constraint(equalTo: bottomBlurEffectView.leadingAnchor, constant: 16),
            affordLabel.trailingAnchor.constraint(equalTo: bottomBlurEffectView.trailingAnchor, constant: -16),

            affordTableView.leadingAnchor.constraint(equalTo: bottomBlurEffectView.leadingAnchor, constant: 16),
            affordTableView.trailingAnchor.constraint(equalTo: bottomBlurEffectView.trailingAnchor, constant: -16),
            affordTableView.heightAnchor.constraint(equalToConstant: 96),

            percentagePickerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            percentagePickerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            percentagePickerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            percentagePickerStackView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.35),

            percentageToolbar.heightAnchor.constraint(equalToConstant: 44),

            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }
}

extension AffordabilityMainViewController: TableOverlayViewDelegate {
    func overlay(_ overlay: TableOverlayView, isOpen: Bool) {
        if isOpen {
            openConstraint?.priority = .required
            helpButton.isHidden = true
        } else {
            openConstraint?.priority = UILayoutPriority(1.0)
            helpButton.isHidden = false
        }

        overlay.tableView?.isScrollEnabled = isOpen

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            overlay.tableView?.reloadData()
        }, completion: nil)
    }
}

extension AffordabilityMainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        guard let viewModel else { return 0 }
        return viewModel.monthlyPercentages[viewModel.chosenMonth]?.count ?? 0
    }

    func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
        guard let viewModel, let depositPercentage = viewModel.monthlyPercentages[viewModel.chosenMonth]?[row] else { return nil }
        return NSAttributedString(string: (depositPercentage.description) + "%", attributes: [.foregroundColor: UIColor.white])
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        viewModel?.selectPercentage(row)
    }

    func pickerView(_: UIPickerView, rowHeightForComponent _: Int) -> CGFloat {
        return 32
    }
}

extension AffordabilityMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if tableView != affordTableView {
            if openConstraint?.priority == .required {
                return viewModel?.overlayData?.details.count ?? 0
            } else {
                return 1
            }
        }
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        if tableView == affordTableView {
            return 32
        } else {
            return 48
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let styles, let vm = viewModel else { return UITableViewCell() }

        if tableView == affordTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AffordabilityMainAffordTableViewCell.reuseIdentifier, for: indexPath) as? AffordabilityMainAffordTableViewCell else { return UITableViewCell() }

            cell.style(styles: styles)
            let month = vm.affordabilityCalculations.first { $0.selected }
            let calculations = month?.homeCalculations.first { $0.isSelected }

            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Home Value"
                cell.amountLabel.text = calculations?.homeValue.shortDescription
                cell.percentageLabel.isHidden = true
                cell.chevronImageView.isHidden = true
            case 1:
                cell.titleLabel.text = "Deposit"
                cell.titleLabel.textColor = styles.colors.buttons.primaryDark.fill.color
                cell.percentageLabel.text = (vm.affordabilityCalculations.first(where: { $0.selected })?.depositPercentage.description ?? "") + "%"
                cell.percentageLabel.textColor = styles.colors.buttons.primaryDark.fill.color
                cell.percentageLabel.isHidden = false
                cell.amountLabel.text = calculations?.depositValue.shortDescription
                cell.amountLabel.textColor = styles.colors.buttons.primaryDark.fill.color
                cell.chevronImageView.isHidden = false
            default:
                cell.titleLabel.text = "Fee & Cost Estimations"
                cell.amountLabel.text = calculations?.fees.shortDescription
                cell.percentageLabel.isHidden = true
                cell.chevronImageView.isHidden = true
            }

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AffordabilityMainOverlayTableViewCell.reuseIdentifier, for: indexPath) as? AffordabilityMainOverlayTableViewCell else { return UITableViewCell() }

            cell.style(styles: styles)
            cell.chevronIcon.isHidden = true

            if openConstraint?.priority == .required {
                if let name = vm.overlayData?.details[indexPath.row].icon {
                    if let icon = UIImage(named: name, in: uiBundle, compatibleWith: nil) {
                        cell.icon.image = icon
                    } else if let icon = UIImage(systemName: name) {
                        cell.icon.image = icon
                    }
                }
                cell.titleLabel.text = vm.overlayData?.details[indexPath.row].title
                cell.valueLabel.text = vm.overlayData?.details[indexPath.row].value
            } else {
                if let name = vm.overlayData?.info.icon {
                    if let icon = UIImage(named: name, in: uiBundle, compatibleWith: nil) {
                        cell.icon.image = icon
                    } else if let icon = UIImage(systemName: name) {
                        cell.icon.image = icon
                    }
                }

                cell.titleLabel.text = vm.overlayData?.info.title
                cell.chevronIcon.isHidden = false
                cell.valueLabel.text = vm.overlayData?.info.value
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == affordTableView {
            if indexPath.row == 1 {
                percentagePickerStackView.isHidden = false
                if let vm = viewModel {
                    switch vm.viewType {
                    case .tabbar:
                        navigationController?.tabBarController?.tabBar.isHidden = true
                    default:
                        break
                    }
                }
            }
        } else {
            if openConstraint?.priority == UILayoutPriority(1.0) {
                overlayView.open()
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection _: Int) -> UIView? {
        if tableView != affordTableView {
            if openConstraint?.priority == .required {
                guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AffordabilityMainOverlayFooterView.reuseIdentifier) as? AffordabilityMainOverlayFooterView else { return nil }

                footerView.setup(title: "Note: These are rough estimates to serve as a guide only. The exact details of the mortgages that will be available to you when you apply will vary.")
                if let styles {
                    footerView.style(styles: styles)
                }

                return footerView
            } else {
                let view = UIView()
                view.backgroundColor = .clear
                return view
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        if tableView != affordTableView {
            if openConstraint?.priority == .required {
                return UITableView.automaticDimension
            } else {
                return view.safeAreaInsets.bottom
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        if tableView != affordTableView {
            if openConstraint?.priority == .required {
                guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AffordabilityMainOverlayHeaderView.reuseIdentifier) as? AffordabilityMainOverlayHeaderView,
                      let vm = viewModel, let data = vm.overlayData else { return nil }

                if let icon = UIImage(named: data.info.icon, in: uiBundle, compatibleWith: nil) {
                    headerView.setup(title: data.info.title, icon: icon)
                } else if let icon = UIImage(systemName: data.info.icon) {
                    headerView.setup(title: data.info.title, icon: icon)
                }

                if let styles {
                    headerView.style(styles: styles)
                }

                return headerView
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        if tableView != affordTableView {
            if openConstraint?.priority == .required {
                return UITableView.automaticDimension
            }
        }
        return 0
    }
}

extension AffordabilityMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel?.months.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        guard let vm = viewModel else { return .zero }
        let height = Int(collectionView.frame.width) / vm.months.count
        return CGSize(width: height, height: height >= 56 ? 56 : height)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AffordabilityMonthsCollectionViewCell.reuseIdentifier,
            for: indexPath) as? AffordabilityMonthsCollectionViewCell,
              let vm = viewModel
        else { return UICollectionViewCell() }
        
        if vm.months[indexPath.row] == 0 {
            cell.label.text = "NOW"
        } else if vm.months[indexPath.row] == 36 {
            cell.label.text = vm.months[indexPath.row].description + "+"
        } else {
            cell.label.text = vm.months[indexPath.row].description
        }

        if let styles {
            cell.apply(styles: styles)
        }

        if let styles, let calculations = vm.affordabilityCalculations.first(where: { $0.selected }) {
            calculations.homeCalculations.forEach { calculation in
                if calculation.monthlyPeriod == vm.months[indexPath.row] {
                    if calculation.valid || vm.firstValidMonthlyPeriod < calculation.monthlyPeriod {
                        cell.isUserInteractionEnabled = true
                        cell.rectangleView.isHidden = !calculation.isSelected
                        cell.label.textColor = calculation.isSelected ? styles.colors.buttons.primaryDark.fill.color : .white
                    } else {
                        cell.isUserInteractionEnabled = false
                        cell.label.textColor = .lightGray
                        cell.rectangleView.isHidden = true
                    }
                }
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vm = viewModel else { return }

        vm.currentMonthRow = indexPath.row
        vm.affordabilityCalculations.enumerated().forEach { index, _ in
            vm.affordabilityCalculations[index].homeCalculations.enumerated().forEach { i, item in
                vm.affordabilityCalculations[index].homeCalculations[i].isSelected = item.monthlyPeriod == vm.months[indexPath.row]
            }
        }

        vm.getMonths()
        collectionView.reloadData()
    }
}

extension AffordabilityMainViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}

extension AffordabilityMainViewController: DashboardBindable {
    func bind(styles: AppStyles = AppStyles.shared) {
        bind(type: .tabbar, getStartedType: nil, isDashboard: false)
    }

    func resume() {
        viewModel?.resume()
    }
}

extension AffordabilityMainViewController {
    func nextButtonHandle() {
        guard let vm = viewModel else { return }

        switch vm.viewType {
        case .setGoal, .dashboard:
            vm.showPropertySearch()
        case .filter:
            vm.showResults()
        case .tabbar:
            break
        }
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
        showNotifications()
    }

    @objc func onHelpButtonTap() {
        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            alertView.heightAnchor.constraint(equalToConstant: view.frame.height / 1.75)
        ])
    }
    
    func showNotifications() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = NotificationsCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }

    @objc func onInfoButtonTap() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = AffordabilityInformationCarouselCoordinator(presenter: presenter, isDashboard: true)
                coordinator.start()
            })
        }
    }
}
