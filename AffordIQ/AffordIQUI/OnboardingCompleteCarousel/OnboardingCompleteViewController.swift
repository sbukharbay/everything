//
//  OnboardingCompleteViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 16/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class OnboardingCompleteViewController: FloatingButtonController, Stylable, ViewController, ErrorPresenter {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "star_background", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let headerLabel: TitleLabelBlue = {
        let label = TitleLabelBlue()
        label.text = "CONGRATULATIONS! "
        label.textAlignment = .center
        return label
    }()

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "070728")
        return view
    }()

    private let alfieImage: UIImageView = {
        let alfie = UIImageView()
        alfie.image = UIImage(named: "alfie_on_rocket", in: uiBundle, compatibleWith: nil)
        alfie.contentMode = .scaleAspectFit
        return alfie
    }()

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "", rightButtonTitle: "Next") { [weak self] in
            self?.backButtonHandle()
        } rightButtonAction: { [weak self] in
            self?.nextButtonHandle()
        }
        return navBar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(OnboardingCompleteViewCell.self, forCellWithReuseIdentifier: OnboardingCompleteViewCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private lazy var pageControl: UIPageControl = {
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

    var viewModel: OnboardingCompleteViewModel?
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

        alfieImage.shake()
        
        viewModel = OnboardingCompleteViewModel()
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
                self?.customNavBar.rightButton(isEnabled: true)
                self?.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.moveToDashboardSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] willMove in
                guard willMove else { return }
                self?.moveToDashboard()
            }
            .store(in: &subscriptions)
    }

    func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pointX = targetContentOffset.pointee.x
        pageControl.currentPage = Int(pointX / view.frame.width)
    }

    func nextButtonHandle() {
        guard let strongVm = viewModel else { return }
        if let viewModel, pageControl.currentPage == strongVm.pages.count - 1 {
            customNavBar.rightButton(isEnabled: false)
            
            Task {
                await viewModel.showDashboard()
            }
        } else {
            let nextIndex = min(pageControl.currentPage + 1, strongVm.pages.count - 1)
            let indexPath = IndexPath(item: nextIndex, section: 0)
            pageControl.currentPage = nextIndex
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    func backButtonHandle() {
        if pageControl.currentPage == 0 {
            navigationController?.popViewController(animated: true)
        } else {
            let nextIndex = max(pageControl.currentPage - 1, 0)
            let indexPath = IndexPath(item: nextIndex, section: 0)
            pageControl.currentPage = nextIndex
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func moveToDashboard() {
        perform(action: { [weak self] _ in
            if let presenter = self?.navigationController {
                presenter.dismiss(animated: true) {
                    self?.viewModel?.logEvent(key: OnboardingStep.completeOnboarding.rawValue)
                    
                    let dashboardCoordinator = DashboardCoordinator(presenter: presenter)
                    dashboardCoordinator.start()
                }
            }
        })
    }

    @objc func pageControlSelection() {
        changePage(index: pageControl.currentPage)
    }

    func changePage(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    private func setupViews() {
        [backgroundImageView, headerView, headerLabel, alfieImage, collectionView, pageControl, customNavBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            headerView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 40),

            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 40),
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            alfieImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            alfieImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alfieImage.heightAnchor.constraint(equalToConstant: view.frame.height / 3),

            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageControl.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -48)
        ])
    }
}

extension OnboardingCompleteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel?.pages.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCompleteViewCell.reuseIdentifier, for: indexPath) as? OnboardingCompleteViewCell else { return UICollectionViewCell() }

        if let vm = viewModel, let styles {
            cell.setupData(text: vm.pages[indexPath.item])
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

extension UIView {
    func shake() {
        transform = CGAffineTransform(translationX: 2, y: 2)
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 4, options: .repeat, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

extension OnboardingCompleteViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let styles {
            apply(styles: styles)
        }
    }
}
