//
//  RenewConsentViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 31.07.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class RenewConsentViewController: FloatingButtonController, Stylable {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)
    
    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Renew Consent"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(RenewConsentTableViewCell.self, forCellReuseIdentifier: RenewConsentTableViewCell.reuseIdentifier)
        return tableView
    }()

    private let backgroundDarkView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#0F0728")
        return view
    }()
    
    private lazy var confirmButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Confirm", for: .normal)
        button.addTarget(self, action: #selector(confirmButtonHandle), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: InlineButtonDark = {
        let button = InlineButtonDark()
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(backButtonHandle), for: .touchUpInside)
        return button
    }()

    private var viewModel: RenewConsentViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
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

    func bind(accounts: [[InstitutionAccount]], preReconsentType: PreReconsentType) {
        loadViewIfNeeded()

        viewModel = RenewConsentViewModel(accounts: accounts, type: preReconsentType)
        setupListeners()
        
        setupViews()
        apply(styles: AppStyles.shared)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    private func setupListeners() {
        viewModel?.$reconsent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reconsent in
                guard let reconsent else { return }
                self?.reconsent(reconsent)
            }
            .store(in: &subscriptions)
    }
    
    @objc func confirmButtonHandle() {
        viewModel?.confirm()
    }
    
    func reconsent(_ model: ReconsentRequestModel) {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = ReconsentProcessingCoordinator(presenter: presenter, providers: model, preReconsentType: self.viewModel?.preReconsentType)
                coordinator.start()
            })
        }
    }

    func setupViews() {
        [backgroundImageView, backButton, blurEffectView, headerLabel, tableView, backgroundDarkView, confirmButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            
            blurEffectView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: backgroundDarkView.topAnchor, constant: -24),
            
            headerLabel.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 8),
            headerLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -16),
            
            backgroundDarkView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundDarkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundDarkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundDarkView.heightAnchor.constraint(equalToConstant: 72),
            backgroundDarkView.topAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -8),
            
            confirmButton.leadingAnchor.constraint(equalTo: backgroundDarkView.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: backgroundDarkView.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 40),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    @objc private func backButtonHandle() {
        navigationController?.popViewController(animated: true)
    }
}

extension RenewConsentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.accounts.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel, let cell = tableView.dequeueReusableCell(withIdentifier: RenewConsentTableViewCell.reuseIdentifier, for: indexPath) as? RenewConsentTableViewCell else { return UITableViewCell() }
        cell.setup(accounts: vm.accounts[indexPath.row]) { renew in
            vm.renew[indexPath.row] = renew
        }
        cell.style(styles: AppStyles.shared)
        return cell
    }
}

extension RenewConsentViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
