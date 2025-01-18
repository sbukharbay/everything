//
//  FeedbackFormViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 28.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class FeedbackFormViewController: UIViewController, Stylable, ErrorPresenter {
    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "") { [weak self] in
            self?.complete()
        }
        return navBar
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "text.bubble")
        imageView.tintColor = UIColor(hex: "72F0F0")
        return imageView
    }()

    private lazy var headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Feedback"
        return label
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, headerLabel])
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: iconImageView)
        stackView.axis = .horizontal
        return stackView
    }()

    private let reasonTitle: BodyLabelDark = {
        let label = BodyLabelDark()
        label.numberOfLines = 0
        label.text = "Please select a reason for your feedback"
        return label
    }()

    private let reasonError: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Please select one"
        label.isHidden = true
        return label
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

    private let descriptionTitle: BodyLabelDark = {
        let label = BodyLabelDark()
        label.numberOfLines = 0
        label.text = "Description"
        return label
    }()

    private lazy var descriptionTextView: TextViewDark = {
        let textView = TextViewDark()
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.delegate = self
        return textView
    }()

    private let descriptionError: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Please provide a description"
        label.isHidden = true
        return label
    }()

    private let counterLabel: FieldLabelDarkRight = {
        let label = FieldLabelDarkRight()
        label.text = "1000"
        return label
    }()

    private lazy var submitButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()

    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var viewModel: FeedbackFormViewModel?
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

    func bind(styles: AppStyles = AppStyles.shared, className: String) {
        loadViewIfNeeded()

        viewModel = FeedbackFormViewModel(className: className)
        
        setupViews()
        setupListeners()
        
        self.styles = styles
        apply(styles: styles)
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
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
        
        // Pop feedback view after completion
        viewModel?.$isCompleted
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isCompleted in
                guard isCompleted else { return }
                self?.complete()
            })
            .store(in: &subscriptions)
        
        // Listener shows error text
        viewModel?.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willShow in
                guard willShow else { return }
                self?.showError()
            }
            .store(in: &subscriptions)
    }

    private func setupViews() {
        view.backgroundColor = UIColor(hex: "0F0728")

        [horizontalStackView, reasonTitle, reasonError, tableView, descriptionTitle, descriptionTextView, descriptionError, counterLabel, submitButton, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 24),
            horizontalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            iconImageView.heightAnchor.constraint(equalToConstant: 26),
            iconImageView.widthAnchor.constraint(equalToConstant: 26),

            reasonTitle.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: 32),
            reasonTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            reasonTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            reasonTitle.heightAnchor.constraint(equalToConstant: 20),

            reasonError.topAnchor.constraint(equalTo: reasonTitle.bottomAnchor, constant: 8),
            reasonError.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            reasonError.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            reasonError.heightAnchor.constraint(equalToConstant: 16),

            tableView.topAnchor.constraint(equalTo: reasonError.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            tableView.heightAnchor.constraint(equalToConstant: 200),

            descriptionTitle.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            descriptionTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descriptionTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            descriptionTitle.heightAnchor.constraint(equalToConstant: 32),

            descriptionTextView.topAnchor.constraint(equalTo: descriptionTitle.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            descriptionError.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            descriptionError.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            descriptionError.trailingAnchor.constraint(equalTo: counterLabel.leadingAnchor),
            descriptionError.heightAnchor.constraint(equalToConstant: 32),

            counterLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            counterLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            counterLabel.heightAnchor.constraint(equalToConstant: 32),

            submitButton.topAnchor.constraint(equalTo: descriptionError.bottomAnchor, constant: 16),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            submitButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func handleSubmit() {
        if let description = descriptionTextView.text {
            if description.isEmpty {
                descriptionError.isHidden = false
            }
            Task {
                await viewModel?.submit(comment: description)
            }
        }
    }

    func showError() {
        reasonError.isHidden = false
    }

    func complete() {
        let transition = CATransition()
        transition.type = .push
        transition.subtype = .fromRight
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
}

extension FeedbackFormViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 1000
    }

    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            counterLabel.text = (1000 - text.count).description

            if !descriptionError.isHidden {
                descriptionError.isHidden = true
            }
        }
    }
}

extension FeedbackFormViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel?.reasons.count ?? 0
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmploymentStatusTableViewCell.reuseIdentifier, for: indexPath) as? EmploymentStatusTableViewCell, let vm = viewModel else { return UITableViewCell() }
        cell.titleLabel.text = vm.reasons[indexPath.row].reason
        cell.toggle(vm.reasons[indexPath.row].selected)
        
        if let styles {
            cell.apply(styles: styles)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vm = viewModel else { return }

        if !reasonError.isHidden {
            reasonError.isHidden = true
        }

        for index in vm.reasons.indices {
            viewModel?.reasons[index].selected = false
        }

        viewModel?.reasons[indexPath.row].selected.toggle()

        tableView.reloadData()
    }
}

extension FeedbackFormViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        guard let styles else { return }
        apply(styles: styles)
    }
}
