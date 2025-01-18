//
//  JourneyViewController.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 05/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import Combine

class JourneyViewController: UIViewController, Stylable {
    private lazy var signInButton: SecondaryButtonDark = {
        let button = SecondaryButtonDark()
        button.setTitle("Sign In", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        return button
    }()

    private lazy var journeyPageControl: UIPageControl = {
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

    private lazy var nextButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Next", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(JourneyPageCell.self, forCellWithReuseIdentifier: JourneyPageCell.reuseIdentifier)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()

    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [journeyPageControl, nextButton, signInButton])
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "milestone_opal_background", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    var viewModel: JourneyViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
        
        let vm = JourneyViewModel()
        viewModel = vm
        setupViews()
        apply(styles: vm.styles)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }

    fileprivate func setupViews() {
        [backgroundImageView, collectionView, buttonStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            buttonStackView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pointX = targetContentOffset.pointee.x
        journeyPageControl.currentPage = Int(pointX / view.frame.width)
    }

    @objc private func handleSignIn() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = StateLoaderCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }

    @objc private func handleNext() {
        guard let viewModel else { return }

        if journeyPageControl.currentPage == (viewModel.pages.count - 1) {
            if let presenter = navigationController {
                let getStartedCoordinator = GetStartedCoordinator(presenter: presenter, type: .initial)
                getStartedCoordinator.start()
            }
        } else {
            let nextIndex = min(journeyPageControl.currentPage + 1, viewModel.pages.count - 1)
            let indexPath = IndexPath(item: nextIndex, section: 0)
            journeyPageControl.currentPage = nextIndex
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    @objc private func pageControlSelection() {
        let indexPath = IndexPath(item: journeyPageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension JourneyViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel?.pages.count ?? 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JourneyPageCell.reuseIdentifier, for: indexPath) as? JourneyPageCell, let vm = viewModel else { return UICollectionViewCell() }
        cell.setup(page: vm.pages[indexPath.row], styles: vm.styles, isLast: vm.pages.count == indexPath.row + 1) { [weak self] safariViewController in
            self?.present(safariViewController, animated: true, completion: nil)
        }
        
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}

extension JourneyViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        if let viewModel {
            apply(styles: viewModel.styles)
        }
    }
}
