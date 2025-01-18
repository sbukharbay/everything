//
//  SpendingSubCategoryViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 27/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class SpendingCategoryViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {  [weak self] in
        let navBar = CustomNavigationBar(title: "Own Your Finances", rightButtonTitle: "Save") {
            self?.navigationController?.popViewController(animated: true)
        } rightButtonAction: {
            self?.navigationController?.popViewController(animated: true)
            self?.viewModel?.saveCategoryData()
        }
        return navBar
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "spending", in: uiBundle, compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private let headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Spending"
        return label
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, headerLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.setCustomSpacing(12, after: iconImageView)
        stackView.alignment = .bottom
        return stackView
    }()

    private let infoLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Select a category"
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(SpendingCategoryTableViewCell.self, forCellReuseIdentifier: SpendingCategoryTableViewCell.reuseIdentifier)
        tableView.register(SpendingSubCategoryTableViewCell.self, forCellReuseIdentifier: SpendingSubCategoryTableViewCell.reuseIdentifier)
        tableView.register(SpendingCategoryHeaderViewCell.self, forCellReuseIdentifier: SpendingCategoryHeaderViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    var viewModel: SpendingCategoryViewModel?
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

        contentSizeMonitor.removeObserver()
    }

    func bind(styles: AppStyles = AppStyles.shared, completion: @escaping ((ChildCategoriesModel) -> Void)) {
        loadViewIfNeeded()

        viewModel = SpendingCategoryViewModel(completion: completion)

        setupViews()
        setupListeners()
        
        self.styles = styles
        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
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
        
        viewModel?.updateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willUpdate in
                guard let self, willUpdate else { return }
                self.update()
            }
            .store(in: &subscriptions)
    }

    func update() {
        tableView.reloadData()
    }

    private func setupViews() {
        [backgroundImageView, blurEffectView, titleStackView, infoLabel, tableView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),

            titleStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 24),
            titleStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            infoLabel.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),

            tableView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -16)
        ])
        customNavBar.hideRightButton(hide: true)
    }
}

extension SpendingCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        if viewModel?.isCategory == true {
            return 1
        } else {
            return 2
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel?.isCategory == true {
            return viewModel?.categories.count ?? 0
        } else {
            if section == 0 {
                return 1
            }
            return viewModel?.selectedCategory?.childCategory.count ?? 0
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 48
        }
        return 32
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel?.isCategory == true {
            viewModel?.isCategory = false
            viewModel?.selectedCategory = viewModel?.categories[indexPath.row]
        } else {
            if indexPath.section == 0 {
                viewModel?.isCategory = true
                viewModel?.selectedCategory = nil
                viewModel?.selectedSubCategory = nil
            } else {
                viewModel?.selectedSubCategory = viewModel?.selectedCategory?.childCategory[indexPath.row]
            }
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel?.isCategory == true {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SpendingCategoryTableViewCell.reuseIdentifier, for: indexPath) as? SpendingCategoryTableViewCell else { return UITableViewCell() }

            if let vm = viewModel, let styles {
                cell.setupLayout(with: vm.categories[indexPath.row])
                cell.style(styles: styles)
                infoLabel.text = "Select a category"
            }
            return cell
        } else {
            if indexPath.section == 0 {
                guard let headerCell = tableView.dequeueReusableCell(withIdentifier: SpendingCategoryHeaderViewCell.reuseIdentifier, for: indexPath) as? SpendingCategoryHeaderViewCell else { return UITableViewCell() }
                if let vm = viewModel, let styles {
                    guard let selected = vm.selectedCategory else { return UITableViewCell() }
                    headerCell.setup(with: selected)
                    headerCell.style(styles: styles)
                }
                return headerCell
            } else {
                guard let subCell = tableView.dequeueReusableCell(withIdentifier: SpendingSubCategoryTableViewCell.reuseIdentifier, for: indexPath) as? SpendingSubCategoryTableViewCell else { return UITableViewCell() }

                if let vm = viewModel, let styles {
                    infoLabel.text = "Please select a sub-category"
                    subCell.style(styles: styles)
                    subCell.subCategoryLabel.text = vm.selectedCategory?.childCategory[indexPath.row].categoryName

                    if viewModel?.selectedSubCategory?.categoryName == vm.selectedCategory?.childCategory[indexPath.row].categoryName {
                        subCell.subCategoryLabel.font = subCell.subCategoryLabel.font.fontWith(weight: .bold)
                        subCell.checkIcon.isHidden = false
                        customNavBar.hideRightButton(hide: false)
                    } else {
                        subCell.checkIcon.isHidden = true
                        subCell.subCategoryLabel.font = subCell.subCategoryLabel.font.fontWith(weight: .regular)
                    }
                }
                return subCell
            }
        }
    }
}

extension SpendingCategoryViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
