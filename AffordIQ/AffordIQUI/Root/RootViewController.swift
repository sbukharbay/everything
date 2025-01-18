//
//  RootViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 19/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import AffordIQAuth0

public class RootViewController: UIViewController, Stylable {
    
    @IBOutlet weak var bottomStackView: UIStackView!
    
    var session: SessionType?
    private var contentSizeMonitor: ContentSizeMonitor = .init()

    override public func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        contentSizeMonitor.removeObserver()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let session = session, session.isAuthenticated {
            session.logout { [weak self] error in

                if let error = error {
                    self?.present(error: error) {
                        self?.showLogin()
                    }
                    return
                }

                self?.showLogin()
            }
        } else {
            showLogin()
        }
    }

    func bind(styles: AppStyles = AppStyles.shared) {
        loadViewIfNeeded()

        self.session = Auth0Session.shared
        apply(styles: styles)
    }

    func showLogin() {
        UIView.animate(withDuration: 0.5) {
            self.bottomStackView.alpha = 1
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        view.isUserInteractionEnabled = false
        
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = StateLoaderCoordinator(presenter: presenter)
                coordinator.start()
            })
        }
    }
    
    @IBAction func beginJourney(_ sender: Any) {
        view.isUserInteractionEnabled = false
        
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let journeyCoordinator = JourneyCoordinator(presenter: presenter)
                journeyCoordinator.start()
            })
        }
    }
}

extension RootViewController: ContentSizeMonitorDelegate, ErrorPresenter {
    public func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}

extension RootViewController: StoryboardInstantiable {
    public static func instantiate() -> Self? {
        return instantiate(storyboard: "Root", identifier: nil)
    }
}
