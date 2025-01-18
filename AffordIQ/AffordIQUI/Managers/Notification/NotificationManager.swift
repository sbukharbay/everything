//
//  NotificationState.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 22/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import Combine
import AffordIQAuth0
import AffordIQFoundation
import UIKit

public final class NotificationManager: NotificationProtocol {
    public static let shared = NotificationManager()
    
    // Notification counter
    @Published public var notificationCounter: Int
    var notificationCounterPublished: Published<Int> { _notificationCounter }
    var notificationCounterPublisher: Published<Int>.Publisher { $notificationCounter }
    // Notification list
    @Published public var notifications: [NotificationDTO] = []
    var notificationsPublished: Published<[NotificationDTO]> { _notifications }
    var notificationsPublisher: Published<[NotificationDTO]>.Publisher { $notifications }
    
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        notificationCounter = GeneralPreferences.shared.notificationCounter
        
        notifications = getNotifications()
        setupListeners()
    }
    
    func setupListeners() {
        _notificationCounter.projectedValue
            .sink { newValue in
                GeneralPreferences.shared.notificationCounter = newValue
            }
            .store(in: &subscriptions)
    }
    
    /// Set notification bagde count to 0
    public func cleanCounterBadge() {
        notificationCounter = 0
    }
    
    /// Create notification, add it to list, calling saving, increasing badge count
    public func addNotification(
        withTitle title: String,
        description: String,
        date: Date = Date(),
        userID: String? = Auth0Session.shared.userID
    ) {
        let notification = NotificationDTO(
            title: title,
            description: description,
            date: date,
            userID: userID
        )
        notifications.append(notification)
        
        increaseCounter()
        saveNotifications()
    }
    
    /// Increase badge counter
    private func increaseCounter() {
        notificationCounter += 1
    }
    
    /// Encode notification list and save data into general preferences
    private func saveNotifications() {
        if let encodedNotifications = try? JSONEncoder().encode(notifications) {
            GeneralPreferences.shared.notificationList = encodedNotifications
        }
    }
    
    /// Read data from General preferences and decode it into notification list
    private func getNotifications() -> [NotificationDTO] {
        guard let notificationsData = GeneralPreferences.shared.notificationList,
              let notificationsDecoded = try? JSONDecoder()
            .decode(Array.self, from: notificationsData) as [NotificationDTO] else { return [] }
    
        return notificationsDecoded
    }
    
    /// Reducing badge count on home screen's icon by some number
    public func reduceNotificationIconBadgeCountToZero() {
        let key = "@shared_storage.notifications_count"
        
        guard let combinedDefaults = UserDefaults(suiteName: "group.com.blackarrowgroup.affordiq") else { return }
        combinedDefaults.register(defaults: [key: 1])
        
        // If stored value is 0 badge is not appearing after new notification comes
        // that is why stoping at 1
        let count = 1
        combinedDefaults.set(count, forKey: key)
        combinedDefaults.synchronize()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /// Reducing badge count on home screen's icon by some number
    public func reduceNotificationIconBadgeCount(by value: Int = 1) {
        guard let userDefaults = UserDefaults(suiteName: NotificationGroupName.blackarrowgroup.group) else {
            return
        }
        
        var count = userDefaults.integer(forKey: "count")
        count -= value
        
        // If stored value is 0 badge is not appearing after new notification comes
        // that is why stoping at 1
        // swiftlint:disable empty_count
        if count != 0 {
            userDefaults.set(count, forKey: "count")
        }
        // swiftlint:enable empty_count
        
        UIApplication.shared.applicationIconBadgeNumber = count
    }
}
