//
//  TermsViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 13/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import SafariServices
import UIKit
import WebKit
import Combine

class TermsViewController: UIViewController, Stylable, ErrorPresenter, ViewController {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "registration", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let labelHeader: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Registration"
        return label
    }()

    private lazy var imageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, labelHeader])
        stackView.axis = .horizontal
        stackView.setCustomSpacing(8, after: iconImageView)
        return stackView
    }()

    private let labelContent: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "Please read the below Terms and Conditions and accept to continue"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var blurEffectStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageStackView, labelContent])
        view.axis = .vertical
        view.alignment = .center
        view.setCustomSpacing(12, after: imageStackView)
        view.layer.cornerRadius = 30
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.isLayoutMarginsRelativeArrangement = true
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private let termsView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private lazy var agreeButton: DarkBlueButton = {
        let button = DarkBlueButton()
        button.setTitle("I Agree", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(onAgreeButtonTap), for: .touchUpInside)
        return button
    }()

    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        button.tintColor = UIColor(hex: "99A0AA")
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        button.addTarget(self, action: #selector(onCheckButtonTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let agreeLabel: FieldLabelSubheadlineLight = {
        let label = FieldLabelSubheadlineLight()
        label.text = "I have read and agree to affordIQ Terms & Conditions"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var checkView: UIView = {
        let view = UIView()
        view.addSubview(checkButton)
        view.addSubview(agreeLabel)
        return view
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [checkView, agreeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alpha = 0.0
        stackView.backgroundColor = .white
        return stackView
    }()

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Get Started", leftButtonAction: nil)
        navBar.hideLeftButton(hide: true)
        return navBar
    }()

    private lazy var webKitView: WKWebView = {
        let webView = WKWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.contentMode = .scaleAspectFit
        webView.layer.cornerRadius = 30
        webView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        webView.layer.masksToBounds = true
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        return webView
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = UIColor(hex: "72F0F0")
        indicator.style = .large
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var checked: Bool = false
    private var viewModel: TermsViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    private var styles: AppStyles?

    override func viewDidLoad() {
        super.viewDidLoad()

        contentSizeMonitor.delegate = self
        webKitView.scrollView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        contentSizeMonitor.removeObserver()
    }

    func bind(styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        openUrl()

        viewModel = TermsViewModel()
        setupViews()
        setupListeners()
        
        self.styles = styles
        apply(styles: styles)
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
        
        // Listener for next step
        viewModel?.$nextStep
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nextStep in
                guard let nextStep, nextStep == .linkBankAccounts else { return }
                self?.showGetStarted()
            }
            .store(in: &subscriptions)
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    func setupViews() {
        [backgroundImageView, blurEffectView, blurEffectStack, termsView, webKitView, bottomStackView, activityIndicatorView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: blurEffectStack.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: blurEffectStack.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: blurEffectStack.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: blurEffectStack.bottomAnchor),
            
            blurEffectStack.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            termsView.topAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: 24),
            termsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            termsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            termsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            webKitView.topAnchor.constraint(equalTo: termsView.topAnchor),
            webKitView.leadingAnchor.constraint(equalTo: termsView.leadingAnchor),
            webKitView.trailingAnchor.constraint(equalTo: termsView.trailingAnchor),
            webKitView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),

            activityIndicatorView.centerXAnchor.constraint(equalTo: webKitView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: webKitView.centerYAnchor),

            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),

            checkButton.heightAnchor.constraint(equalToConstant: 32),
            checkButton.widthAnchor.constraint(equalToConstant: 32),
            checkButton.leadingAnchor.constraint(equalTo: checkView.leadingAnchor),
            checkButton.centerYAnchor.constraint(equalTo: checkView.centerYAnchor),

            agreeLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            agreeLabel.centerYAnchor.constraint(equalTo: checkView.centerYAnchor),
            agreeLabel.trailingAnchor.constraint(equalTo: checkView.trailingAnchor),
            agreeLabel.topAnchor.constraint(equalTo: checkView.topAnchor),
            agreeLabel.bottomAnchor.constraint(equalTo: checkView.bottomAnchor),

            agreeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func openUrl() {
        if let url = URL(string: "https://app.termly.io/document/terms-of-use-for-ios-app/87c4cc74-6413-4956-b48f-eccab3963fd3"), !url.absoluteString.isEmpty {
            let myRequest = URLRequest(url: url)
            webKitView.load(myRequest)
        }
    }
    
    func showGetStarted() {
        perform(action: { _ in
            if let presenter = navigationController {
                presenter.dismiss(animated: true, completion: {
                    let coordinator = FeedbackCoordinator(presenter: presenter)
                    coordinator.start()
                })
            }
        })
    }

    @objc func onCheckButtonTap() {
        checked.toggle()

        if checked {
            checkButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkButton.tintColor = .systemTeal
            agreeButton.isEnabled = true
        } else {
            checkButton.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
            checkButton.tintColor = UIColor(hex: "99A0AA")
            agreeButton.isEnabled = false
        }
    }

    @objc func onAgreeButtonTap() {
        Task {
            await viewModel?.setUserAgree()
            await viewModel?.checkCurrentState()
        }
    }
}

extension TermsViewController: WKNavigationDelegate, UIScrollViewDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.activityIndicatorView.stopAnimating()
        }
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        activityIndicatorView.stopAnimating()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if webKitView.scrollView.contentSize.height > 1000 {
            if scrollView.contentOffset.y > webKitView.scrollView.contentSize.height - webKitView.frame.height - 48 {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.bottomStackView.alpha = 1.0
                })
            } else {
                UIView.animate(withDuration: 0.1, animations: { [weak self] in
                    self?.bottomStackView.alpha = 0.0
                })
            }
        }
    }
}

extension TermsViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
