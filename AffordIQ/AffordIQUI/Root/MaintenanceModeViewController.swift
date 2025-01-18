//
//  MaintenanceModeViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 17.02.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit
import AffordIQControls

public class MaintenanceModeViewController: UIViewController, Stylable {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)
    
    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()
    
    private let titleLabel: TitleLabelBlue = {
        let label = TitleLabelBlue()
        Task {
            label.text = await FirebaseDBManager.shared.maintenanceHeader
        }
        return label
    }()
    
    private let messageLabel: HeadingLabelInfo = {
        let label = HeadingLabelInfo()
        label.numberOfLines = 0
        label.textAlignment = .center
        Task {
            label.text = await FirebaseDBManager.shared.maintenanceTXT1
        }
        return label
    }()
    
    private let backMessageLabel: HeadingLabelInfo = {
        let label = HeadingLabelInfo()
        label.numberOfLines = 0
        label.textAlignment = .center
        Task {
            label.text = await FirebaseDBManager.shared.maintenanceTXT2
        }
        return label
    }()
    
    private lazy var closeButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Close App", for: .normal)
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }()
    
    private let blueView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "0F0728")
        view.layer.cornerRadius = 30
        return view
    }()
    
    private let alfiImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "maintenance", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var styles: AppStyles
    
    public init(styles: AppStyles) {
        self.styles = styles
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
        setupViews()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }
    
    func setupViews() {
        [backgroundImageView, blurEffectView, blueView, alfiImage, titleLabel, messageLabel, backMessageLabel, closeButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            blurEffectView.bottomAnchor.constraint(equalTo: blueView.bottomAnchor, constant: 72),
            
            blueView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 48),
            blueView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            blueView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            blueView.bottomAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 32),
            
            alfiImage.topAnchor.constraint(equalTo: blueView.topAnchor, constant: 32),
            alfiImage.leadingAnchor.constraint(equalTo: blueView.leadingAnchor, constant: 24),
            alfiImage.trailingAnchor.constraint(equalTo: blueView.trailingAnchor, constant: -24),
            alfiImage.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: alfiImage.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: blueView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: blueView.trailingAnchor, constant: -24),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: blueView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: blueView.trailingAnchor, constant: -24),
            
            backMessageLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            backMessageLabel.leadingAnchor.constraint(equalTo: blueView.leadingAnchor, constant: 24),
            backMessageLabel.trailingAnchor.constraint(equalTo: blueView.trailingAnchor, constant: -24),
            
            closeButton.topAnchor.constraint(equalTo: backMessageLabel.bottomAnchor, constant: 32),
            closeButton.centerXAnchor.constraint(equalTo: blueView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 144),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        apply(styles: styles)
    }
    
    @objc private func handleClose() {
        UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
    }
}

extension MaintenanceModeViewController: ContentSizeMonitorDelegate {
    public func contentSizeCategoryUpdated() {
        apply(styles: styles)
    }
}
