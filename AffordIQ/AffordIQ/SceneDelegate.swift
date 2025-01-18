//
//  SceneDelegate.swift
//  AffordIQ
//
//  Created by Sultangazy Bukharbay on 19/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQUI
import Siren
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    weak var privacyView: UIView?

    func scene(_: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .critical, showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)
        siren.apiManager = APIManager(country: .unitedKingdom, bundleID: Bundle.main.bundleIdentifier)
        siren.wail()
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        NotificationManager.shared.reduceNotificationIconBadgeCountToZero()
        privacyView?.removeFromSuperview()
        privacyView = nil
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        if let window = window {
            let imageView = UIImageView(frame: window.bounds)
            imageView.tintColor = UIColor.white
            imageView.image = UIImage(named: "logo_background")
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = UIColor(hex: "0F0728")
            window.addSubview(imageView)

            privacyView = imageView
        }
    }
}

extension SceneDelegate {
    func scene(_: UIScene, continue userActivity: NSUserActivity) {
        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL
        else {
            return
        }

        let holder = HolderView.shared
        holder.next(url: incomingURL.description)
    }
}
