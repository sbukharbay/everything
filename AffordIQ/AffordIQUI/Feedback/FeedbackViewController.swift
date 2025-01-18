//
//  FeedbackViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 26.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class FeedbackViewController: FloatingButtonController, Stylable {
    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "", rightButtonTitle: "Next") { [weak self] in
            self?.handleBack()
        } rightButtonAction: { [weak self] in
            self?.handleNext()
        }
        return navBar
    }()

    private let headerLabel: TitleLabelBlue = {
        let view = TitleLabelBlue()
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textAlignment = .left
        
        return view
    }()

    private let descriptionLabel: FieldLabelDark = {
        let label = FieldLabelDark()
        label.numberOfLines = 0
        return label
    }()

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "white_long_arrow", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var index = 0
    private var data: [FeedbackModel] = [
        FeedbackModel(
            title: "WE NEED YOUR FEEDBACK",
            description: "Your feedback is very important to us. The more we know about your experience the better."
                + "\n\nWe want to know when you are confused about what to do. We want to know when the app doesn't work properly. We want to know about the things you like and we want to know about the things you don't like.",
            hasIcon: false
        ),
        FeedbackModel(
            title: "FEEDBACK TAB",
            description: "To give feedback at any point while using the affordIQ app, tap the feedback tab at the bottom left of the screen.\n\nPlease give feedback as many times as you wish. The more the better.",
            hasIcon: true
        )
    ]

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

        update()
        setupViews()
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

    private func setupViews() {
        view.backgroundColor = UIColor(hex: "0F0728")

        [headerLabel, descriptionLabel, arrowImageView, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 180),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 56),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            arrowImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            arrowImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            arrowImageView.heightAnchor.constraint(equalToConstant: 300),
            arrowImageView.widthAnchor.constraint(equalToConstant: 180)
        ])

        bringFeedbackButton(String(describing: type(of: self)))
    }

    private func handleNext() {
        if index == 0 {
            index = 1
            update()
        } else {
            if let presenter = navigationController {
                presenter.dismiss(animated: true, completion: {
                    let coordinator = GetStartedCoordinator(presenter: presenter, type: .registered)
                    coordinator.start()
                })
            }
        }
    }

    private func handleBack() {
        if index == 0 {
            navigationController?.popViewController(animated: true)
        } else {
            index = 0
            update()
        }
    }

    private func update() {
        headerLabel.text = data[index].title
        descriptionLabel.text = data[index].description

        feedbackButton.isHidden = !data[index].hasIcon
        arrowImageView.isHidden = !data[index].hasIcon
    }
}

extension FeedbackViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
