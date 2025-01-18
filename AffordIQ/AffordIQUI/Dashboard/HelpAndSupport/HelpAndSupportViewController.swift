//
//  HelpAndSupportViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 15/08/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import SafariServices
import UIKit
import WebKit

class HelpAndSupportViewController: FloatingButtonController, Stylable, WKNavigationDelegate {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let navBar = CustomNavigationBar(title: "Help & Support") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()

    private lazy var overlayView: TableOverlayView = {
        let view = TableOverlayView(frame: .zero)
        view.tabVisible = false
        view.heading = nil
        view.title = nil
        return view
    }()

    private lazy var webKitView: WKWebView = {
        let webView = WKWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.contentMode = .scaleAspectFit
        webView.layer.cornerRadius = 20
        webView.layer.masksToBounds = true
        return webView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top),

            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom)
        ])
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var styles: AppStyles?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()

        navigationController?.isNavigationBarHidden = true
    }

    func bind(styles: AppStyles = AppStyles.shared, isTerms: Bool) {
        loadViewIfNeeded()

        if isTerms {
            openTermsUrl()
            customNavBar.setTitle(text: "Terms & Conditions")
        } else {
            openHelpUrl()
        }

        setupViews()
        
        self.styles = styles
        apply(styles: styles)
        
        bringFeedbackButton(String(describing: type(of: self)))
    }

    private func setupViews() {
        [backgroundImageView, overlayView, webKitView, customNavBar, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 8),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),

            webKitView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 16),
            webKitView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            webKitView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            webKitView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -8),
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func openHelpUrl() {
        if let url = URL(string: "https://affordiq.com/support"), !url.absoluteString.isEmpty {
            let myRequest = URLRequest(url: url)
            webKitView.load(myRequest)
        }
    }

    private func openTermsUrl() {
        if let url = URL(string: "https://app.termly.io/document/terms-of-use-for-ios-app/87c4cc74-6413-4956-b48f-eccab3963fd3"), !url.absoluteString.isEmpty {
            let myRequest = URLRequest(url: url)
            webKitView.load(myRequest)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        present(error: error)
        activityIndicator.stopAnimating()
    }
}
            
extension HelpAndSupportViewController: ErrorPresenter { }

extension HelpAndSupportViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
