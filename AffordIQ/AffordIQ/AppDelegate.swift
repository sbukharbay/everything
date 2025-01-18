//
//  AppDelegate.swift
//  AffordIQ
//
//  Created by Sultangazy Bukharbay on 19/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQUI
import AffordIQAuth0
import Amplitude
import FirebaseCore
import FirebaseInAppMessaging
import FirebaseMessaging
import IQKeyboardManagerSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true

        Amplitude.instance().defaultTracking.sessions = true

        #if DEBUG
        if ProcessInfo.processInfo.environment["DISABLEALLANIMATIONS"] == "true" {
            UIView.setAnimationsEnabled(false)
        }

        configureGoogle(name: "GoogleService-Info-development")

        Amplitude.instance().initializeApiKey("ba2aed7365a3bdd38db3b35131f4b72e")
        #else
        configureGoogle(name: Bundle.main.bundleIdentifier == "com.blackarrowgroup.affordiq.demo" ? "GoogleService-Info-staging" : "GoogleService-Info")
            
        Amplitude.instance().initializeApiKey("60d6369dbc1261a19d7a3fa283f995d3")
        #endif

        Amplitude.instance().logEvent("APP_START")

        FirebaseConfiguration.shared.setLoggerLevel(.min)

        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]) { _, _ in }

        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self
        InAppMessaging.inAppMessaging().delegate = self

        return true
    }

    func configureGoogle(name: String) {
        let filePath = Bundle.main.path(forResource: name, ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
    }

    func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if Auth0Session.handle(url: url, options: options) {
            return true
        }
        return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([[.banner, .sound]])
        } else {
            completionHandler([[.alert, .badge, .sound]])
        }

        NotificationManager.shared.addNotification(
            withTitle: notification.request.content.title,
            description: notification.request.content.body
        )
        
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive _: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Amplitude.instance().logEvent("NOTIFICATION_RECEIVED")
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: tokenDict)
    }
}

extension AppDelegate: InAppMessagingDisplayDelegate { }
