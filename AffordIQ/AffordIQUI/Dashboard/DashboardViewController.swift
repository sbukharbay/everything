//
//  DashboardViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 20/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import AffordIQAuth0
import SafariServices
import UIKit
import AffordIQNetworkKit

class DashboardViewController: UITabBarController, ErrorPresenter {
    let session: SessionType = Auth0Session.shared
    var childCoordinators: [DashboardResumableCoordinator] = []
    private var userSource: UserSource = UserService()
    
    var observer: AnyObject?
    var userID: String?
    var dashboardLoaded: Bool = false
    var styles = AppStyles.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.accessibilityIdentifier = "Dashboard"
        delegate = self
        
        observer = NotificationCenter.default.addObserver(forName: DashboardCoordinator.logoutRequested, object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    func bind() {
        loadViewIfNeeded()
        
        tabBar.backgroundColor = styles.colors.buttons.primaryDark.text.color
        tabBar.tintColor = styles.colors.buttons.primaryDark.fill.color
        tabBar.unselectedItemTintColor = .white

        apply(styles: styles)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        loadDashboardIfNeeded()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        if parent == nil {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item), index < 4 {
            childCoordinators[index].resume()
        }
    }
}

extension DashboardViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SliderTransition(viewControllers: tabBarController.viewControllers)
    }
}

extension DashboardViewController {
    func loadDashboardIfNeeded() {
        loadDashboard()
    }

    private func loadDashboard(userID: String) {
        self.userID = userID

        asyncIfRequired { [weak self] in
            guard let dashboard = self else { return }
            var childCoordinators: [DashboardResumableCoordinator] = []
            
            let homeCoordinator = HomeCoordinator(presenter: dashboard)
            homeCoordinator.start()
            childCoordinators.append(homeCoordinator)
            
            let goalsCoodinator = GoalsCoordinator(presenter: dashboard)
            goalsCoodinator.start()
            childCoordinators.append(goalsCoodinator)
            
            let budgetCoordinator = BudgetCoordinator(presenter: dashboard)
            budgetCoordinator.start()
            childCoordinators.append(budgetCoordinator)
            
            let affordabilityCoordinator = AffordabilityMainCoordinator(type: .tabbar, tabBarController: dashboard, isDashboard: true)
            affordabilityCoordinator.start()
            childCoordinators.append(affordabilityCoordinator)
            
            dashboard.childCoordinators = childCoordinators
            dashboard.apply(styles: dashboard.styles)
            
            dashboard.selectedIndex = 0
        }
    }
    
    func handleLoadingError(error: Error) {
        present(error: error) { [weak self] in
            self?.session.clearCredentials()
            self?.navigationController?.popToRootViewController(animated: false)
            BusyView.shared.hide()
        }
    }

    func loadDashboard() {
        if let userID = session.userID {
            loadDashboard(userID: userID)
        } else if let externalUserID = session.user?.externalUserId {
            Task {
                await self.getUserId(externalUserID)
            }
        }
    }
    
    @MainActor
    func getUserId(_ externalID: String) async {
        do {
            let response = try await userSource.getUserID(externalID: externalID)
            if let userID = response.userID {
                loadDashboard(userID: userID)
                Auth0Session.shared.userID = userID
            }
        } catch {
            present(error: error) { [weak self] in
                self?.session.clearCredentials()
                self?.navigationController?.popToRootViewController(animated: false)
                BusyView.shared.hide()
            }
        }
    }
}

extension DashboardViewController: Stylable {
    func apply(styles: AppStyles) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: styles.fonts.sansSerif.footnote
        ]

        for child in children {
            let tabBarItem = child.tabBarItem
            tabBarItem?.setTitleTextAttributes(attributes, for: .normal)
        }
    }
}

extension DashboardViewController: StoryboardInstantiable {
    static func instantiate() -> Self? {
        return instantiate(storyboard: "Dashboard", identifier: nil)
    }
}

extension DashboardViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: styles)
    }
}
