//
//  LinkAccountsInformationViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 22/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class LinkAccountsInformationViewController: FloatingButtonController, Stylable {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Get Started", rightButtonTitle: "Next") { [weak self] in
            self?.backButtonHandle()
        } rightButtonAction: { [weak self] in
            self?.nextButtonHandle()
        }
        return navBar
    }()

    private lazy var linkPageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = viewModel?.pages.count ?? 0
        pc.currentPageIndicatorTintColor = UIColor(hex: "72F0F0")
        pc.pageIndicatorTintColor = .lightGray
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.addTarget(self, action: #selector(pageControlSelection), for: .valueChanged)
        if #available(iOS 14.0, *) {
            pc.allowsContinuousInteraction = false
        }
        pc.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        }
        return pc
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(LinkAccountsInformationViewCell.self, forCellWithReuseIdentifier: LinkAccountsInformationViewCell.reuseIdentifier)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()

    private lazy var videoButton: InlineButtonDark = {
        let button = InlineButtonDark()
        button.setTitle("   Watch Video", for: .normal)
        let buttonImage = UIImage(systemName: "questionmark.video.fill")
        button.setImage(buttonImage, for: .normal)
        button.imageView?.layer.transform = CATransform3DMakeScale(1.4, 1.4, 1.4)
        button.addTarget(self, action: #selector(videoPlayOnButtonTap), for: .touchUpInside)
        return button
    }()

    private lazy var linkAccountsButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Link Bank Accounts", for: .normal)
        button.addTarget(self, action: #selector(linkAccountsOnButtonTap), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [videoButton, linkPageControl])
        stackView.distribution = .fill
        stackView.setCustomSpacing(16, after: videoButton)
        stackView.axis = .vertical
        return stackView
    }()

    var viewModel: LinkAccountsInformationViewModel?
    var isBack = false
    private var contentSizeMonitor: ContentSizeMonitor = .init()

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

    func bind() {
        loadViewIfNeeded()

        viewModel = LinkAccountsInformationViewModel()
        setupViews()
        apply(styles: AppStyles.shared)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    func back() {
        isBack = true
        customNavBar.hideRightButton(hide: false)
    }

    func setupViews() {
        [backgroundImageView, collectionView, buttonStackView, linkAccountsButton, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            buttonStackView.bottomAnchor.constraint(equalTo: linkAccountsButton.topAnchor, constant: -8),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            buttonStackView.heightAnchor.constraint(equalToConstant: 80),

            linkAccountsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            linkAccountsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            linkAccountsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            linkAccountsButton.heightAnchor.constraint(equalToConstant: 48),

            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pointX = targetContentOffset.pointee.x
        linkPageControl.currentPage = Int(pointX / view.frame.width)
        hideButtons()
    }

    @objc private func videoPlayOnButtonTap() {
        linkAccountsVideo()
    }

    @objc private func linkAccountsOnButtonTap() {
        showLinkAccounts()
    }

    @objc private func pageControlSelection() {
        changePage(index: linkPageControl.currentPage)
        hideButtons()
    }

    func nextButtonHandle() {
        if linkPageControl.currentPage == 0 {
            linkPageControl.currentPage = 1
            changePage(index: linkPageControl.currentPage)
            hideButtons()
        } else {
            showLinkedAccounts()
        }
    }

    func backButtonHandle() {
        if linkPageControl.currentPage == 0 {
            navigationController?.popViewController(animated: true)
        } else {
            changePage(index: 0)
            linkPageControl.currentPage = 0
            hideButtons()
        }
    }

    func changePage(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func hideButtons() {
        if !isBack {
            customNavBar.hideRightButton(hide: linkPageControl.currentPage != 0)
        }
        linkAccountsButton.isHidden = linkPageControl.currentPage == 0
    }
    
    func showLinkAccounts() {
        if let presenter = navigationController {
            let chooseProviderCoordinator = ChooseProviderCoordinator(presenter: presenter)
            chooseProviderCoordinator.start()
        }
    }

    func linkAccountsVideo() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let linkAccountsVideoCoordinator = LinkAccountsVideoCoordinator(presenter: presenter)
                linkAccountsVideoCoordinator.start()
            })
        }
    }

    func showLinkedAccounts() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = AccountsCoordinator(presenter: presenter, isBack: false)
                coordinator.start()
            })
        }
    }
}

extension LinkAccountsInformationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel?.pages.count ?? 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkAccountsInformationViewCell.reuseIdentifier, for: indexPath) as? LinkAccountsInformationViewCell else { return UICollectionViewCell() }
        cell.page = viewModel?.pages[indexPath.item]
        cell.apply(styles: AppStyles.shared)

        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}

extension LinkAccountsInformationViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
