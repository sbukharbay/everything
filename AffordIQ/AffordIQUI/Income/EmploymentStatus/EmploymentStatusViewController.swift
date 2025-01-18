//
//  EmploymentStatusViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class EmploymentStatusViewController: FloatingButtonController, Stylable, ErrorPresenter {
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

    private let descriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "The first step to understanding the kind of home you can afford is understanding your income."
        label.numberOfLines = 0
        return label
    }()

    private let questionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.text = "What is your employment status?"
        label.numberOfLines = 0
        return label
    }()
    
//    private let infoLabel: FieldLabelDark = {
//        let label = FieldLabelDark()
//        label.textAlignment = .left
//        label.numberOfLines = 0
//        label.text = "affordIQ will soon cater for people who are self-employed. If you are self-employed, you can continue but you will be considered employed and your experience will not match your circumstances."
//        return label
//    }()
//    
//    private let infoIcon: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.tintColor = UIColor(hex: "#72F0F0")
//        imageView.image = UIImage(systemName: "info.circle")
//        return imageView
//    }()
//
//    private lazy var infoStackView: UIStackView = {
//        let stack = UIStackView(arrangedSubviews: [infoIcon, infoLabel])
//        stack.axis = .horizontal
//        stack.distribution = .fill
//        stack.spacing = 8
//        stack.alignment = .top
//        return stack
//    }()

    var viewModel: EmploymentStatusViewModel?
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
        [backgroundImageView, blurEffectView, topStackView, descriptionLabel, questionLabel, tableView, customNavBar].forEach {
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

            descriptionLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),

            questionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            questionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 120)
            
//            infoStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
//            infoStackView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
//            infoStackView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
//            infoStackView.heightAnchor.constraint(equalToConstant: 136),
            
//            infoIcon.heightAnchor.constraint(equalToConstant: 28),
//            infoIcon.widthAnchor.constraint(equalToConstant: 28)
        ])
    }

    func bind(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool) {
        loadViewIfNeeded()

        viewModel = EmploymentStatusViewModel(incomeData: incomeData, getStartedType: getStartedType, isSettings: isSettings)
        setupListeners()
        
        setupViews()
        apply(styles: AppStyles.shared)

        bringFeedbackButton(String(describing: type(of: self)))
    }
    
    func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let error else { return }
                self.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.$showNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] next in
                guard let self else { return }
                self.showNext()
            }
            .store(in: &subscriptions)
        
        viewModel?.$confirmIncome
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                guard let self else { return }
                self.showSummary()
            }
            .store(in: &subscriptions)
    }

    private func nextButtonHandle() {
        if let selected = viewModel?.statuses.first(where: { $0.selected }) {
            viewModel?.showNext(selected)
        }
    }

    private func updateButtonHandle() {
        if let selected = viewModel?.statuses.first(where: { $0.selected }) {
            viewModel?.confirmIncomeSummary(selected)
        }
    }
    
    private func showNext() {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                if viewModel.isSelfEmployed {
                    let coordinator = SelfEmployedTypeCoordinator(presenter: presenter, incomeData: viewModel.incomeData, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                    coordinator.start()
                } else {
                    let coordinator = SetSalaryCoordinator(presenter: presenter, incomeData: viewModel.incomeData, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                    coordinator.start()
                }
            })
        }
    }
    
    private func showSummary() {
        if let presenter = navigationController, let viewModel, let data = viewModel.incomeData {
            presenter.dismiss(animated: true, completion: {
                let confirmIncomeCoordinator = ConfirmIncomeCoordinator(presenter: presenter, incomeData: data, getStartedType: viewModel.getStartedType, isSettings: viewModel.isSettings)
                confirmIncomeCoordinator.start()
            })
        }
    }
}

extension EmploymentStatusViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel?.statuses.count ?? 0
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmploymentStatusTableViewCell.reuseIdentifier, for: indexPath) as? EmploymentStatusTableViewCell, let vm = viewModel else { return UITableViewCell() }
        cell.titleLabel.text = vm.statuses[indexPath.row].status.getText()
        cell.toggle(vm.statuses[indexPath.row].selected)
        cell.apply(styles: AppStyles.shared)
        
//        if indexPath.row == 1 {
//            cell.disabled()
//        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
            guard let vm = viewModel else { return }
            
            if vm.incomeData?.salary != nil {
                customNavBar.addRightButton(title: "Update") { [weak self] in
                    self?.updateButtonHandle()
                }
            } else {
                if vm.statuses.allSatisfy({ $0.selected == false }) {
                    customNavBar.addRightButton(title: "Next") { [weak self] in
                        self?.nextButtonHandle()
                    }
                }
            }

            for index in vm.statuses.indices {
                viewModel?.statuses[index].selected = false
            }

            viewModel?.statuses[indexPath.row].selected.toggle()
            tableView.reloadData()
//        }
    }
}

extension EmploymentStatusViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
