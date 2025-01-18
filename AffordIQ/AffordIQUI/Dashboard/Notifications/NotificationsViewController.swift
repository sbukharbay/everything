//
//  NotificationsViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 04.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class NotificationsViewController: FloatingButtonController, Stylable {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let navBar = CustomNavigationBar(title: "Notifications") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()
    
    private lazy var emptyLabel: InfoLabel = {
        let label = InfoLabel()
        label.isHidden = true
        label.textAlignment = .center
        label.text = "You currently have no notifications."
        
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.reuseIdentifier)
        return tableView
    }()

    private var viewModel: NotificationsViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
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
        
        viewModel?.cleanNotifications()
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

    func bind(styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        viewModel = NotificationsViewModel()
        customNavBar.addRightButton(image: UIImage(systemName: "bell") ?? UIImage(), color: UIColor(hex: "72F0F0"), action: nil)

        setupViews()
        self.styles = styles
        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
        
        setupListeners()
    }
    
    func setupListeners() {
        // Listen for notification list in viewModel to refresh table
        viewModel?.$notificationSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                guard let self else { return }
                self.emptyLabel.isHidden = !sections.isEmpty
                self.tableView.reloadData()
            }
            .store(in: &subscriptions)
    }

    func setupViews() {
        tableView.backgroundColor = .white

        [backgroundImageView, tableView, customNavBar, emptyLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyLabel.topAnchor.constraint(equalTo: view.topAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        let section = viewModel.notificationSections[section]
        
        return section.notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? NotificationTableViewCell else { return UITableViewCell() }
        guard let viewModel else { return UITableViewCell() }
            
        let section = viewModel.notificationSections[indexPath.section]
        let notification = section.notifications[indexPath.row]
        
        cell.setupNotification(notification)
        
        if let styles {
            cell.style(styles: styles)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let viewModel else { return nil }
        
        let section = viewModel.notificationSections[section]
        let date = section.month
        let dateFormatter = DateFormatter()
        
        if date.isInSameYear(as: Date()) {
            dateFormatter.dateFormat = "MMMM"
        } else {
            dateFormatter.dateFormat = "MMMM yyyy"
        }
        
        return dateFormatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.systemFont(ofSize: 14)
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel else { return 0 }
        return viewModel.notificationSections.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension NotificationsViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
