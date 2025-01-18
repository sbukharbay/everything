//
//  MilestoneInformationViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 09/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

class MilestoneInformationViewController: FloatingButtonController, Stylable, ViewController {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "milestone_opal_background", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var milestonePageControl: UIPageControl = {
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

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(MilestoneInformationViewCell.self, forCellWithReuseIdentifier: MilestoneInformationViewCell.reuseIdentifier)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "", rightButtonTitle: "Next") { [weak self] in
            self?.handleBack()
        } rightButtonAction: { [weak self] in
            self?.handleNext()
        }
        return navBar
    }()

    var viewModel: MilestoneInformationViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var styles: AppStyles?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }

    func bind(type: CarouselViewType, styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        viewModel = MilestoneInformationViewModel(type: type)
        setupViews()
        
        self.styles = styles
        apply(styles: styles)
    }

    func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pointX = targetContentOffset.pointee.x
        milestonePageControl.currentPage = Int(pointX / view.frame.width)
    }

    @objc private func pageControlSelection() {
        let indexPath = IndexPath(item: milestonePageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    @objc func handleNext() {
        if milestonePageControl.currentPage == 1 {
            switch viewModel?.viewType {
            case .ownYourFinances:
                startSetCompass()
            case .ownYourFuture:
                startAffordability()
            default:
                break
            }
        } else {
            milestonePageControl.currentPage = 1
            pageControlSelection()
        }
    }
    
    func startSetCompass() {
        perform(action: { _ in
            if let presenter = navigationController {
                let coordinator = EmploymentStatusCoordinator(presenter: presenter)
                coordinator.start()
            }
        })
    }
    
    func startAffordability() {
        perform(action: { _ in
            if let presenter = navigationController {
                let coordinator = AffordabilityInformationCarouselCoordinator(presenter: presenter)
                coordinator.start()
            }
        })
    }

    @objc func handleBack() {
        if milestonePageControl.currentPage == 1 {
            milestonePageControl.currentPage = 0
            pageControlSelection()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func setupViews() {
        [backgroundImageView, collectionView, milestonePageControl, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            milestonePageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            milestonePageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            milestonePageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            milestonePageControl.heightAnchor.constraint(equalToConstant: 40)
        ])

        bringFeedbackButton(String(describing: type(of: self)))
    }
}

extension MilestoneInformationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel?.pages.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MilestoneInformationViewCell.reuseIdentifier, for: indexPath) as? MilestoneInformationViewCell else { return UICollectionViewCell() }

        switch viewModel?.pages[indexPath.item] {
        case let .single(item):
            cell.setupSingleLayout(model: item)
        case let .many(items):
            cell.setupManyLayout(model: items)
        default:
            break
        }

        switch viewModel?.viewType {
        case .ownYourFinances:
            cell.headerLabel.text = "OWN YOUR FINANCES"
        case .ownYourFuture:
            cell.headerLabel.text = "OWN YOUR FUTURE"
        default:
            break
        }

        if let styles {
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

extension MilestoneInformationViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
