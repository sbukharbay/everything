//
//  LinkAccountsVideoViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 01/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import AVFoundation
import AVKit
import SafariServices
import UIKit
import WebKit

class LinkAccountsVideoViewController: FloatingButtonController, Stylable {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Get Started") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Open Banking"
        return label
    }()

    private lazy var videoView: UIView = {
        let videoView = UIView()
        return videoView
    }()

    private let infoLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "For further information head on over to the Open Banking website"
        label.numberOfLines = 0
        return label
    }()

    private lazy var furtherInfoButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Further Information", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(furtherInfoOnButtonTap), for: .touchUpInside)
        return button
    }()

    func playVideo(embedHTML: String) {
        let webView = WKWebView()
        webView.frame.size.height = videoView.frame.size.height
        webView.frame.size.width = videoView.frame.size.width
        webView.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(webView)
        let url = URL(string: "https://")
        webView.loadHTMLString(embedHTML as String, baseURL: url)
        webView.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    private var contentSizeMonitor: ContentSizeMonitor = .init()
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

    func bind(styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        self.styles = styles
        setupViews()
        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    @objc func furtherInfoOnButtonTap() {
        if let url = URL(string: "https://www.openbanking.org.uk/what-is-open-banking/") {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        let embedHTML = "<style>* { margin: 0; padding: 0; }html, body { width: 100%; height: 100%; }</style><iframe src="
            + "\"https://player.vimeo.com/video/461359425?h=538d2cdb2b&autoplay=1\""
            + " width=\"100%\" height=\"100%\" frameborder=\"0\" allow=\"autoplay; fullscreen; picture-in-picture\" allowfullscreen></iframe>"
        playVideo(embedHTML: embedHTML)
//    if let url = URL(string: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_640_3MG.mp4"){
//      playVideo2(url: url)
//    }

        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    func setupViews() {
        [backgroundImageView, blurEffectView, headerLabel, videoView, furtherInfoButton, infoLabel, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 24),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: furtherInfoButton.bottomAnchor, constant: 40),

            headerLabel.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            videoView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 24),
            videoView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            videoView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9.0 / 16.0),
            videoView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            infoLabel.topAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 32),
            infoLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),

            furtherInfoButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 32),
            furtherInfoButton.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            furtherInfoButton.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            furtherInfoButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

extension LinkAccountsVideoViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
