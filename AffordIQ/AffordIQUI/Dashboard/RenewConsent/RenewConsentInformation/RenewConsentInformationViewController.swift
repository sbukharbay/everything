//
//  RenewConsentInformationViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 27.07.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls
import AffordIQFoundation
import SafariServices
import AffordIQAuth0
import Amplitude

class RenewConsentInformationViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)
    
    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "linked_accounts", in: uiBundle, compatibleWith: nil)
        return imageView
    }()

    private let headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Linked Bank Accounts"
        return label
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, headerLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.setCustomSpacing(16, after: iconImageView)
        return stackView
    }()

    private let subTitleLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .left
        label.text = "affordIQ's partner, TrueLayer, needs your permission to continue accessing your banking data for another 90 days."
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var topLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let questionLabel: FieldLabelBoldDark = {
        let label = FieldLabelBoldDark()
        label.text = "What am I sharing?"
        return label
    }()
    
    private let chevronIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(systemName: "chevron.down"))
        icon.tintColor = UIColor(hex: "#72F0F0")
        return icon
    }()
    
    private lazy var shareStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [questionLabel, chevronIcon])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.setCustomSpacing(16, after: iconImageView)
        return stackView
    }()

    private let truelayerLabel: SmallLabelDark = {
        let label = SmallLabelDark()
        label.textAlignment = .left
        label.text = "Truelayer is FCA-regulated, and won't share or use your personal data for anything else."
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var renewButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Renew Consent", for: .normal)
        button.addTarget(self, action: #selector(renewButtonHandle), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Skip", for: .normal)
        button.addTarget(self, action: #selector(skipButtonHandle), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoutButton: InlineButtonDark = {
        let button = InlineButtonDark()
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(logoutButtonHandle), for: .touchUpInside)
        return button
    }()
    
    private lazy var expandTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToExpand))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()
    
    private lazy var termsLabel: FooterTextView = {
        let textView = FooterTextView()
        
        let text = "By choosing 'Renew Consent', you agree to TrueLayer's Terms of Service and Privacy Policy"
        let termsRange = (text as NSString).range(of: "Terms of Service")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        let termsURL = URL(string: "https://truelayer.com/legal/enduser_tos/")!
        let privacyURL = URL(string: "https://truelayer.com/legal/privacy/")!
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.link, value: termsURL, range: termsRange)
        attributedString.addAttribute(.link, value: privacyURL, range: privacyRange)
        
        textView.attributedText = attributedString
        textView.tintColor = UIColor(hex: "#72F0F0")
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.delegate = self
        
        return textView
    }()
    
    private let expandLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.textAlignment = .left
        label.text = "To provide you with meaningful financial insights,"
        + " TrueLayer needs permission to access the following information and share it with affordIQ"
        + "\n\n  - Full Name\n  - Account number and sort code\n  - Balance\n  - Transactions"
        label.numberOfLines = 0
        return label
    }()
    
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var isOpen: Bool = false
    private var accounts: [[InstitutionAccount]] = []
    private var closedHeight: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
        navigationController?.isNavigationBarHidden = true
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }

    func bind(accounts: [[InstitutionAccount]]) {
        loadViewIfNeeded()
        
        shareStackView.addGestureRecognizer(expandTapGesture)
        
        self.accounts = accounts
        
        setupViews()
        apply(styles: AppStyles.shared)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    private func setupViews() {
        [backgroundImageView, blurEffectView, topStackView, subTitleLabel, topLine, shareStackView, expandLabel, bottomLine, truelayerLabel, renewButton, skipButton, logoutButton, termsLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        closedHeight = expandLabel.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            topStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            
            subTitleLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 24),
            subTitleLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            subTitleLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            topLine.heightAnchor.constraint(equalToConstant: 0.5),
            topLine.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 16),
            topLine.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            topLine.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            shareStackView.topAnchor.constraint(equalTo: topLine.bottomAnchor, constant: 16),
            shareStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            shareStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),
            
            expandLabel.topAnchor.constraint(equalTo: shareStackView.bottomAnchor, constant: 8),
            expandLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            expandLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),
            closedHeight!,
            
            bottomLine.heightAnchor.constraint(equalToConstant: 0.5),
            bottomLine.topAnchor.constraint(equalTo: expandLabel.bottomAnchor, constant: 8),
            bottomLine.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            bottomLine.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            truelayerLabel.topAnchor.constraint(equalTo: bottomLine.bottomAnchor, constant: 8),
            truelayerLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 24),
            truelayerLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),
            
            termsLabel.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -8),
            termsLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            termsLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            termsLabel.heightAnchor.constraint(equalToConstant: 48),
            
            chevronIcon.widthAnchor.constraint(equalToConstant: 20),
            
            logoutButton.bottomAnchor.constraint(equalTo: termsLabel.topAnchor, constant: -8),
            logoutButton.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),
            
            skipButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -8),
            skipButton.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            skipButton.heightAnchor.constraint(equalToConstant: 40),
            
            renewButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -8),
            renewButton.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            renewButton.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            renewButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func tapToExpand(_: UITapGestureRecognizer) {
        isOpen.toggle()
        
        UIView.animate(withDuration: 1) {
            if self.isOpen {
                self.chevronIcon.image = UIImage(systemName: "chevron.up")
                NSLayoutConstraint.deactivate([self.closedHeight!])
            } else {
                self.chevronIcon.image = UIImage(systemName: "chevron.down")
                NSLayoutConstraint.activate([self.closedHeight!])
            }
        }
    }

    @objc private func renewButtonHandle() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = RenewConsentCoordinator(presenter: presenter, accounts: self.accounts)
                coordinator.start()
            })
        }
    }
    
    @objc private func skipButtonHandle() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.removeObject(forKey: StorageKey.reconsentSkipped.key)
            UserDefaults.standard.set(encoded, forKey: StorageKey.reconsentSkipped.key)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func logoutButtonHandle() {
        let userSession: SessionType = Auth0Session.shared
        
        userSession.logout { [weak self] error in
            if let error = error {
                switch error {
                case SessionError.cancelled:
                    break
                default:
                    self?.present(error: error)
                }
                return
            }
        }

        Amplitude.instance().logEvent("LOGOUT")
        userSession.clearCredentials()
        userSession.userID = nil
        
        let rootCoordinator = RootCoordinator()
        rootCoordinator.start()
    }
}

extension RenewConsentInformationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let safariViewController = SFSafariViewController(url: URL)
        safariViewController.modalPresentationStyle = .popover
        present(safariViewController, animated: true, completion: nil)
        
        return false
    }
}

extension RenewConsentInformationViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
