//
//  NotificationProtocol.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 04/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

protocol NotificationProtocol {
    // Notification counter
    var notificationCounter: Int { get }
    var notificationCounterPublished: Published<Int> { get }
    var notificationCounterPublisher: Published<Int>.Publisher { get }
    // Notification list
    var notifications: [NotificationDTO] { get }
    var notificationsPublished: Published<[NotificationDTO]> { get }
    var notificationsPublisher: Published<[NotificationDTO]>.Publisher { get }
    
    func setupListeners()
    func cleanCounterBadge()
    func addNotification(withTitle title: String, description: String, date: Date, userID: String?)
}
