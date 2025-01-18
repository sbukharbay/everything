//
//  SelfEmployedTypeViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 12.12.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class SelfEmployedTypeViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Own Your Finances") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .clear
        tableView.register(EmploymentStatusTableViewCell.self, forCellReuseIdentifier: EmploymentStatusTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        return tableView
    }()

    private let incomeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "income", in: uiBundle, with: nil)
        return imageView
    }()

    private let incomeTitle: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Income"
        return label
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incomeIcon, incomeTitle])
        stackView.distribution = .fill
        stackView.setCustomSpacing(12, after: incomeIcon)
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        return stackView
    }()

    private let questionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "How are you self employed?"
        label.numberOfLines = 0
        return label
    }()

    var viewModel: SelfEmployedTypeViewModel?
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

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    fileprivate func setupViews() {
        [backgroundImageView, blurEffectView, topStackView, questionLabel, tableView, customNavBar].forEach {
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
            blurEffectView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),

            incomeIcon.heightAnchor.constraint(equalToConstant: 32),
            incomeIcon.widthAnchor.constraint(equalToConstant: 32),

            topStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            topStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            
            questionLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    func bind(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool) {
        loadViewIfNeeded()

        viewModel = SelfEmployedTypeViewModel(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
        setupListeners()
        
        customNavBar.addRightButton(title: "Next") { [weak self] in
            self?.nextButtonHandle()
        }
        
        setupViews()
        apply(styles: AppStyles.shared)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    func setupListeners() {
        viewModel?.$showNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showNext in
                guard showNext else { return }
                self?.next()
            }
            .store(in: &subscriptions)
    }
    
    func next() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = SelfEmployedTimeCoordinator(presenter: presenter, incomeData: viewModel.incomeData, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                coordinator.start()
            })
        }
    }
    
    private func nextButtonHandle() {
        viewModel?.next()
    }
}

extension SelfEmployedTypeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel?.types.count ?? 0
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmploymentStatusTableViewCell.reuseIdentifier, for: indexPath) as? EmploymentStatusTableViewCell, let vm = viewModel else { return UITableViewCell() }
        cell.titleLabel.text = vm.types[indexPath.row].type.getText()
        cell.toggle(vm.types[indexPath.row].selected)
        cell.apply(styles: AppStyles.shared)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vm = viewModel else { return }

        for index in vm.types.indices {
            viewModel?.types[index].selected = false
        }

        viewModel?.types[indexPath.row].selected.toggle()
        tableView.reloadData()
    }
}

extension SelfEmployedTypeViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
