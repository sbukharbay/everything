//
//  NotificationManagerMock.swift
//  AffordIQUI
//
//  Created by Asilbek Djamaldinov on 04/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import Combine
@testable import AffordIQUI

class NotificationManagerMock: NotificationProtocol {
    // Notification counter
    @Published var notificationCounter: Int = 0
    var notificationCounterPublished: Published<Int> { _notificationCounter }
    var notificationCounterPublisher: Published<Int>.Publisher { $notificationCounter }
    // Notification list
    @Published var notifications: [NotificationDTO] = []
    var notificationsPublished: Published<[NotificationDTO]> { _notifications }
    var notificationsPublisher: Published<[NotificationDTO]>.Publisher { $notifications }
    
    func setupListeners() {
        
    }
    
    func cleanCounterBadge() {
        notificationCounter = 0
    }
    
    func addNotification(withTitle title: String,
                         description: String,
                         date: Date = Date(),
                         userID: String? = "1122"
    ) {
        notificationCounter += 1
        
        notifications.append(
            NotificationDTO(title: title,
                            description: description,
                            date: date,
                            userID: userID)
        )
    }
}
