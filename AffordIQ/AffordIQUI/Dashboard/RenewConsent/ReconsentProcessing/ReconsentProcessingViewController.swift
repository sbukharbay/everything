//
//  ReconsentProcessingViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 01.08.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation
import AffordIQControls
import Combine
import SafariServices

class ReconsentProcessingViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
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
    
    private lazy var headerLabel: TitleLabelBlueLeft = {
        let label = TitleLabelBlueLeft()
        label.text = "PROCESSING"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var successTitleLabel: TitleLabelBlueLeft = {
        let label = TitleLabelBlueLeft()
        label.text = "NICE WORK!"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, errorIcon, headerLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

    private let titleLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Renew Consent"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subTitleLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var continueButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(continueButtonHandle), for: .touchUpInside)
        return button
    }()

    private lazy var backButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(backButtonHandle), for: .touchUpInside)
        return button
    }()
    
    private lazy var questionView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "72F0F0")
        return imageView
    }()
    
    private lazy var dateLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var okButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Ok", for: .normal)
        button.addTarget(self, action: #selector(okButtonHandle), for: .touchUpInside)
        return button
    }()
    
    private lazy var errorIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "failed", in: uiBundle, compatibleWith: nil)
        imageView.tintColor = UIColor(hex: "#72F0F0")
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var tryAgainButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Try Again", for: .normal)
        button.addTarget(self, action: #selector(handleTryAgain), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Skip", for: .normal)
        button.addTarget(self, action: #selector(skipButtonHandle), for: .touchUpInside)
        return button
    }()
    
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var viewModel: ReconsentProcessingViewModel?
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

    func bind(providers: ReconsentRequestModel, preReconsentType: PreReconsentType) {
        loadViewIfNeeded()
        
        viewModel = ReconsentProcessingViewModel(providers: providers, type: preReconsentType)
        
        setupListeners()
        setupViews()
        apply(styles: AppStyles.shared)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    private func setupListeners() {
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error, error else { return }
                self?.showError()
            }
            .store(in: &subscriptions)
        
        viewModel?.$manualRenew
            .receive(on: DispatchQueue.main)
            .sink { [weak self] renew in
                if let renew, renew {
                    self?.askForReconsent()
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$successReconsent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dates in
                if let dates {
                    self?.successReconsent(dates)
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$noDates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] noDates in
                if let noDates, noDates {
                    self?.okButtonHandle()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func setupViews() {
        [backgroundImageView, blurEffectView, topStackView, alfiImageView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: alfiImageView.bottomAnchor, constant: 96),
            
            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 32),
            topStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            
            alfiImageView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 32),
            alfiImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alfiImageView.heightAnchor.constraint(equalToConstant: view.frame.height / 2),
            
            activityIndicator.widthAnchor.constraint(equalToConstant: 56),
            activityIndicator.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
 
    func askForReconsent() {
        guard let viewModel, let bank = viewModel.trueLayerResponse?.first?.providerID.capitalizedFirstLetter else { return }
        
        alfiImageView.isHidden = true
        topStackView.isHidden = true
        
        subTitleLabel.text = bank + " requires you to renew your consent in your banking app or online."
        
        [titleLabel, subTitleLabel, backButton, continueButton].forEach {
            questionView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(questionView)
        questionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionView.topAnchor.constraint(equalTo: blurEffectView.topAnchor),
            questionView.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor),
            questionView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: questionView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -16),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            subTitleLabel.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 16),
            subTitleLabel.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -16),
            
            backButton.bottomAnchor.constraint(equalTo: questionView.bottomAnchor, constant: -48),
            backButton.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 16),
            backButton.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -16),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            continueButton.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -8),
            continueButton.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        apply(styles: AppStyles.shared)
        
        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    func successReconsent(_ dates: String) {
        alfiImageView.isHidden = true
        topStackView.isHidden = true
        questionView.isHidden = true
        
        dateLabel.text = "We won't ask to renew your consent again for" + dates
        
        [checkmarkImageView, successTitleLabel, dateLabel, okButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            checkmarkImageView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 32),
            checkmarkImageView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 40),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 40),
            
            successTitleLabel.topAnchor.constraint(equalTo: checkmarkImageView.bottomAnchor, constant: 16),
            successTitleLabel.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: successTitleLabel.bottomAnchor, constant: 24),
            dateLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 48),
            dateLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -48),
            
            okButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 32),
            okButton.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            okButton.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            okButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        apply(styles: AppStyles.shared)
        
        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    private func showError() {
        alfiImageView.image = UIImage(named: "alfie_error", in: uiBundle, compatibleWith: nil)
        headerLabel.text = "PROCESSING\nFAILED"
        
        errorIcon.isHidden = false
        alfiImageView.isHidden = false
        topStackView.isHidden = false
        activityIndicator.isHidden = true
        
        [tryAgainButton, skipButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            skipButton.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -16),
            skipButton.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            skipButton.heightAnchor.constraint(equalToConstant: 40),
            
            tryAgainButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -8),
            tryAgainButton.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tryAgainButton.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            tryAgainButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        apply(styles: AppStyles.shared)
    }
    
    @objc private func continueButtonHandle() {
        showProcessing()
        
        guard let viewModel, let link = viewModel.trueLayerResponse?.first?.response.userInputLink, let url = URL(string: link) else { return }
        
        if let presenter = navigationController {
            authenticate(presenter: presenter, authoriseURL: url, delegate: self, errorPresenter: self)
        }
    }
    
    private func showProcessing() {
        headerLabel.text = "PROCESSING"
        alfiImageView.image = UIImage(named: "alfie", in: uiBundle, compatibleWith: nil)
        
        alfiImageView.isHidden = false
        topStackView.isHidden = false
        activityIndicator.isHidden = false
        
        [titleLabel, subTitleLabel, backButton, continueButton].forEach {
            $0.removeFromSuperview()
        }
    }
    
    @objc private func okButtonHandle() {
        guard let viewModel, let navigationController else { return }
        
        switch viewModel.preReconsentType {
        case .accountDetails:
            if let vc = navigationController.viewControllers.last(where: { $0.isKind(of: AccountDetailsViewController.self) }), let accountDetails = vc as? AccountDetailsViewController {
                accountDetails.reload()
                navigationController.popToViewController(accountDetails, animated: true)
            }
        case .accounts:
            if let vc = navigationController.viewControllers.last(where: { $0.isKind(of: AccountsViewController.self) }), let accounts = vc as? AccountsViewController {
                accounts.reload()
                navigationController.popToViewController(accounts, animated: true)
            }
        default:
            if let vc = navigationController.viewControllers.last(where: { $0.isKind(of: HomeViewController.self) }), let home = vc as? HomeViewController {
                navigationController.popToViewController(home, animated: true)
            }
        }
    }
    
    @objc private func backButtonHandle() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleTryAgain() {
        removeButtons()
        showProcessing()
        
        if let trueLayer = viewModel?.trueLayerResponse, trueLayer.isEmpty {
            continueButtonHandle()
        } else {
            Task {
                await viewModel?.reconsent()
            }
        }
    }
    
    @objc private func skipButtonHandle() {
        removeButtons()
        viewModel?.skip()
    }
    
    private func removeButtons() {
        tryAgainButton.removeFromSuperview()
        skipButton.removeFromSuperview()
        errorIcon.isHidden = true
    }
    
    func present(error: Error) {
        showError()
    }
}

extension ReconsentProcessingViewController: OpenBankingAuthorizationDelegate {
    func didCancelAuthorization() {
        showError()
    }

    func didCompleteAuthorization(institutionId: String?, request: RMAuthoriseBank?) {
        if let request = request, let institutionId = institutionId {
            Task {
                await viewModel?.setAuthorised(request: request, id: institutionId)
            }
        } else {
            showError()
        }
    }
}

extension ReconsentProcessingViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
