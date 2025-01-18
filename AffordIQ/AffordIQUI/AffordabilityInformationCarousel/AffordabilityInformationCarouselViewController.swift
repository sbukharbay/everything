//
//  AffordabilityInformationCarouselViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 10/12/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class AffordabilityInformationCarouselViewController: FloatingButtonController, Stylable, ViewController {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = { [weak self] in
        let navBar = CustomNavigationBar(title: "Own Your Future", rightButtonTitle: "Next") { [weak self] in
            self?.handleBack()
        } rightButtonAction: { [weak self] in
            self?.handleNext()
        }
        return navBar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AffordabilityInformationCarouselViewCell.self, forCellWithReuseIdentifier: AffordabilityInformationCarouselViewCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private lazy var affordabilityPageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = viewModel?.pages.count ?? 0
        pc.currentPageIndicatorTintColor = UIColor(hex: "72F0F0")
        pc.pageIndicatorTintColor = .lightGray
        pc.addTarget(self, action: #selector(pageControlSelection), for: .valueChanged)
        if #available(iOS 14.0, *) {
            pc.allowsContinuousInteraction = false
        }
        pc.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        }
        return pc
    }()

    var viewModel: AffordabilityInformationCarouselViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var styles: AppStyles?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func bind(isDashboard: Bool, styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        viewModel = AffordabilityInformationCarouselViewModel(isDashboard: isDashboard)
        setupViews()
        
        self.styles = styles
        apply(styles: styles)

        bringFeedbackButton(String(describing: type(of: self)))
    }

    func setupViews() {
        [backgroundImageView, collectionView, affordabilityPageControl, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            affordabilityPageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),
            affordabilityPageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            affordabilityPageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            affordabilityPageControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pointX = targetContentOffset.pointee.x
        affordabilityPageControl.currentPage = Int(pointX / view.frame.width)

        hideRightButton()
    }

    @objc private func pageControlSelection() {
        let indexPath = IndexPath(item: affordabilityPageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        hideRightButton()
    }

    private func hideRightButton() {
        if let vm = viewModel, vm.isDashboard {
            customNavBar.hideRightButton(hide: affordabilityPageControl.currentPage == 2)
        }

        if affordabilityPageControl.currentPage == 2 {
            customNavBar.renameRightButtonTitle(text: "Savings")
        } else {
            customNavBar.renameRightButtonTitle(text: "Next")
        }
    }

    func handleBack() {
        if affordabilityPageControl.currentPage == 1 {
            affordabilityPageControl.currentPage = 0
            pageControlSelection()
        } else if affordabilityPageControl.currentPage == 2 {
            affordabilityPageControl.currentPage = 1
            pageControlSelection()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func handleNext() {
        if affordabilityPageControl.currentPage == 0 {
            affordabilityPageControl.currentPage = 1
            pageControlSelection()
        } else if affordabilityPageControl.currentPage == 1 {
            affordabilityPageControl.currentPage = 2
            pageControlSelection()
        } else {
            showSetGoal()
        }
    }
    
    func showSetGoal() {
        perform(action: { _ in
            if let presenter = navigationController {
                let coordinator = SetSavingsGoalCoordinator(presenter: presenter)
                coordinator.start()
            }
        })
    }
}

extension AffordabilityInformationCarouselViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel?.pages.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AffordabilityInformationCarouselViewCell.reuseIdentifier, for: indexPath) as? AffordabilityInformationCarouselViewCell else { return UICollectionViewCell() }

        if let vm = viewModel, let styles {
            cell.setupLayout(model: vm.pages[indexPath.row])
            cell.apply(styles: styles)
        }
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}

extension AffordabilityInformationCarouselViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
