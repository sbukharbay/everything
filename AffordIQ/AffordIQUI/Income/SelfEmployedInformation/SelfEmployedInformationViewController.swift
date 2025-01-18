//
//  SelfEmployedInformationViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 06.02.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls
import AffordIQFoundation

class SelfEmployedInformationViewController: FloatingButtonController, Stylable {
    private lazy var backgroundImageView: BackgroundImageView = BackgroundImageView(frame: .zero)
    
    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Own Your Finances", rightButtonTitle: "Next") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: { [weak self] in
            self?.nextButtonHandle()
        }
        return navBar
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        return view
    }()
    
    private let incomeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#72F0F0")
        imageView.image = UIImage(systemName: "info.circle")
        return imageView
    }()
    
    private let incomeTitle: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Information"
        return label
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incomeIcon, incomeTitle])
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: incomeIcon)
        stackView.axis = .horizontal
        stackView.alignment = .top
        return stackView
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()

    private let headerLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "When applying for a mortgage you will need:"
        label.numberOfLines = 0
        return label
    }()
    
    private var contentSizeMonitor: ContentSizeMonitor = ContentSizeMonitor()
    var incomeData: IncomeStatusDataModel?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool?
    
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
    
    fileprivate func setupViews() {
        [backgroundImageView, blurEffectView, topStackView, headerLabel, bottomStackView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 32),
            
            incomeIcon.heightAnchor.constraint(equalToConstant: 24),
            incomeIcon.widthAnchor.constraint(equalToConstant: 24),
            
            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            topStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            
            headerLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 32),
            
            bottomStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
            bottomStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -32),
            bottomStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16)
        ])
    }
    
    func bind(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool) {
        loadViewIfNeeded()
        
        self.incomeData = incomeData
        self.getStartedType = getStartedType
        self.isSettings = isSettings
        
        guard let months = incomeData?.selfEmploymentData?.months else { return }
        
        var data = [months < 24 ?
                    "SA302 self-assessment tax form"
                    : "SA302 self-assessment tax forms for previous 2 years"]
        data.append(months < 24 ?
                    "1 full years worth of finalised accounts, preferably prepared by a certified or charted accountant."
                    : "at least 2 full years worth of finalised accounts, preferably prepared by a certified or charted accountant.")
        data.append("last 3 months of business account transactions")
        data.append(months < 24 ?
                    "if at all possible, evidence of up coming work"
                    : "(optional) evidence of up coming work")
        
        setupInfo(data)
        
        setupViews()
        apply(styles: AppStyles.shared)
        
        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    private func setupInfo(_ data: [String]) {
        data.forEach { text in
            let infoLabel: BodyLabelDark = BodyLabelDark()
            infoLabel.text = "• " + text
            infoLabel.textAlignment = .left
            infoLabel.numberOfLines = 0
            bottomStackView.addArrangedSubview(infoLabel)
        }
    }
    
    private func nextButtonHandle() {
        guard let presenter = navigationController, let isSettings else { return }
        
        presenter.dismiss(animated: true) {
            let confirmIncomeCoordinator = ConfirmIncomeCoordinator(presenter: presenter, incomeData: self.incomeData, getStartedType: self.getStartedType, isSettings: isSettings)
            confirmIncomeCoordinator.start()
        }
    }
}

extension SelfEmployedInformationViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
