//
//  AlfiLoaderViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 27.01.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import NVActivityIndicatorView
import UIKit
import Combine

class AlfiLoaderViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()

    private let headerLabel: TitleLabelBlueLeft = {
        let label = TitleLabelBlueLeft()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let errorLabel: TitleLabelBlueLeft = {
        let label = TitleLabelBlueLeft()
        label.text = "Something has\ngone wrong"
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = UIColor(hex: "72F0F0")
        indicator.style = .large
        indicator.startAnimating()
        return indicator
    }()

    private lazy var alfiImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "alfie", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var completeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .light))
        imageView.tintColor = UIColor(hex: "#72F0F0")
        imageView.isHidden = true
        return imageView
    }()

    private lazy var errorIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "failed", in: uiBundle, compatibleWith: nil)
        imageView.tintColor = UIColor(hex: "#72F0F0")
        imageView.isHidden = true
        return imageView
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UIView(), UIView(), UIView(), UIView(), activityIndicator, errorIcon, completeIcon, headerLabel, UIView()])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()

    private lazy var button: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Next", for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        return button
    }()

    private let infoLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [infoLabel, errorLabel, button])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 24
        return stackView
    }()

    private lazy var bouncingDots: NVActivityIndicatorView = .init(frame: CGRect(x: 0, y: 0, width: 80, height: 40), type: NVActivityIndicatorType.ballPulseSync, color: UIColor(hex: "72F0F0"))

    private var viewModel: AlfiLoaderViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    private var styles: AppStyles?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        contentSizeMonitor.removeObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.tabBarController?.tabBar.isHidden = true
    }

    private func setupViews() {
        [backgroundImageView, blurEffectView, topStackView, alfiImageView, bouncingDots, contentStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            blurEffectView.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 40),
            blurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),

            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 32),
            topStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -8),
            topStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 8),

            alfiImageView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 64),
            alfiImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alfiImageView.heightAnchor.constraint(equalToConstant: view.frame.height / 3),

            contentStackView.topAnchor.constraint(equalTo: bouncingDots.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),
            contentStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            bouncingDots.topAnchor.constraint(equalTo: alfiImageView.bottomAnchor, constant: 48),
            bouncingDots.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -24),
            bouncingDots.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),

            button.widthAnchor.constraint(equalToConstant: 180),
            button.heightAnchor.constraint(equalToConstant: 40),

            completeIcon.widthAnchor.constraint(equalToConstant: 56),
            completeIcon.heightAnchor.constraint(equalToConstant: 56),

            errorIcon.widthAnchor.constraint(equalToConstant: 56),
            errorIcon.heightAnchor.constraint(equalToConstant: 56),

            activityIndicator.widthAnchor.constraint(equalToConstant: 56),
            activityIndicator.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    func bind(
        styles: AppStyles = AppStyles.shared,
        getStartedType: GetStartedViewType,
        isSpending: Bool = false
    ) {
        loadViewIfNeeded()

        backgroundImageView.image = styles.backgroundImages.defaultImage.image

        let vm = AlfiLoaderViewModel(isSpending: isSpending, getStartedType: getStartedType)
        viewModel = vm

        switch vm.currentViewType {
        case .completingCategorisation:
            headerLabel.text = "COMPLETING\nCATEGORISATION..."
        case .processingTransactions:
            headerLabel.text = "PROCESSING\nTRANSACTIONS..."
        }

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
        
        viewModel?.completedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                guard let self else { return }
                self.completed(status: isSuccess)
            }
            .store(in: &subscriptions)
    }

    @objc private func handleButton() {
        guard let vm = viewModel else { return }

        switch vm.currentViewType {
        case .completingCategorisation:
            if vm.isAffordabilityCompleted == true {
                showSpendingSummary()
            } else {
                alfiImageView.image = UIImage(named: "alfie", in: uiBundle, compatibleWith: nil)
                vm.getAffordabilityStatus()
                infoLabel.isHidden = true
                button.isHidden = true
                errorLabel.isHidden = true
                errorIcon.isHidden = true
                activityIndicator.isHidden = false
            }
        case .processingTransactions:
            if vm.isTransactionsCompleted == true {
                if vm.isTransactionsEmpty {
                    showSpendingSummary()
                } else {
                    let text = "I have identified sets of repeating transactions that occur monthly. Please help me verify the categories I have assigned to them."
                    if infoLabel.text == text {
                        showSpendings()
                    } else {
                        infoLabel.text = text
                    }
                }
            } else {
                alfiImageView.image = UIImage(named: "alfie", in: uiBundle, compatibleWith: nil)
                vm.getTransactionsStatus()
                infoLabel.isHidden = true
                button.isHidden = true
                errorLabel.isHidden = true
                errorIcon.isHidden = true
                activityIndicator.isHidden = false
            }
        }
    }

    func completed(status: Bool) {
        if status {
            infoLabel.isHidden = true
            bouncingDots.startAnimating()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.bouncingDots.stopAnimating()
                self?.infoLabel.isHidden = false
                self?.button.isHidden = false
                self?.activityIndicator.isHidden = true
                self?.completeIcon.isHidden = false

                switch self?.viewModel?.currentViewType {
                case .completingCategorisation:
                    self?.headerLabel.text = "CATEGORISATION\nCOMPLETE"
                    self?.infoLabel.text = "Thank you for your help 👍\nThe categorisation of your spending is now complete."
                case .processingTransactions:
                    if let viewModel = self?.viewModel, viewModel.isTransactionsEmpty {
                        self?.infoLabel.text = "You do not have recent transactions"
                        self?.button.setTitle("Done", for: .normal)
                        self?.headerLabel.text = "NO TRANSACTIONS"
                    } else {
                        self?.headerLabel.text = "PROCESSING\nCOMPLETE"
                        self?.infoLabel.text = "I have finished sorting your spending transactions."
                    }
                default:
                    break
                }
            }
        } else {
            switch viewModel?.currentState {
            case let .bouncing(sec):
                infoLabel.isHidden = true
                bouncingDots.startAnimating()
                headerLabel.text = "PROCESSING\nTRANSACTIONS..."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + sec) { [weak self] in
                    switch self?.viewModel?.currentViewType {
                    case .completingCategorisation:
                        self?.viewModel?.currentState = .failure
                        self?.viewModel?.getAffordabilityStatus()
                    case .processingTransactions:
                        if sec == 5.0 {
                            self?.viewModel?.currentState = .textDelay
                        } else {
                            self?.viewModel?.currentState = .coffeeBreak
                        }
                        self?.viewModel?.getTransactionsStatus()
                    default:
                        break
                    }
                }
            case .textDelay:
                bouncingDots.stopAnimating()

                infoLabel.isHidden = false
                infoLabel.text = "Hey there👋, sorry for the delay. I'm busy sorting your banking transactions into spending categories. It shouldn't take too much longer."

                DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) { [weak self] in
                    self?.viewModel?.currentState = .bouncing(3.0)
                    self?.viewModel?.getTransactionsStatus()
                }
            case .coffeeBreak:
                bouncingDots.stopAnimating()

                infoLabel.isHidden = false
                infoLabel.text = "There is still some sorting to do. Now is a good time to take a break. Make a tea or coffee ☕️ and come back in 5-10 mins."

                DispatchQueue.main.asyncAfter(deadline: .now() + 300.0) { [weak self] in
                    self?.viewModel?.currentState = .failure
                    self?.viewModel?.getTransactionsStatus()
                }
            case .failure:
                bouncingDots.stopAnimating()
                alfiImageView.image = UIImage(named: "alfie_error", in: uiBundle, compatibleWith: nil)
                activityIndicator.isHidden = true
                headerLabel.text = "PROCESSING\nFAILED"
                button.isHidden = false
                errorLabel.isHidden = false
                infoLabel.isHidden = true
                errorIcon.isHidden = false

                viewModel?.currentState = .bouncing(5.0)
                button.setTitle("Try Again", for: .normal)
            default:
                break
            }
        }
    }
    
    func showSpendings() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = SpendingConfirmationCoordinator(presenter: presenter, transactions: viewModel.recurringPaymentsResponse, getStartedType: viewModel.getStartedType)
                coordinator.start()
            })
        }
    }
    
    func showSpendingSummary() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: { [weak self] in
                let coordinator = SpendingSummaryCoordinator(presenter: presenter, getStartedType: self?.viewModel?.getStartedType)
                coordinator.start()
            })
        }
    }
}

extension AlfiLoaderViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
