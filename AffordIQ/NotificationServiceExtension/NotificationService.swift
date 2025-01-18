//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Sultangazy Bukharbay on 03/11/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let combinedDefaults = UserDefaults(suiteName: "group.com.blackarrowgroup.affordiq")
    
    private let key = "@shared_storage.notifications_count"
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let combinedDefaults, let bestAttemptContent = bestAttemptContent else { return }
        combinedDefaults.register(defaults: [key: 1])
        
        var count: Int = combinedDefaults.integer(forKey: key)
        print(count)
        
        bestAttemptContent.title = "\(bestAttemptContent.title) "
        bestAttemptContent.body = "\(bestAttemptContent.body) "
        bestAttemptContent.badge = count as NSNumber
        count += 1
        combinedDefaults.set(count, forKey: key)
        combinedDefaults.synchronize()
        
        guard let attachmentURL = bestAttemptContent.userInfo["image"] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        do {
            let imageData = try Data(contentsOf: URL(string: attachmentURL)!)
            guard let attachment = UNNotificationAttachment.download(imageFileIdentifier: "image.jpg", data: imageData, options: nil) else {
                contentHandler(bestAttemptContent)
                return
            }
            bestAttemptContent.attachments = [attachment]
            // swiftlint:disable force_cast
            contentHandler(bestAttemptContent.copy() as! UNNotificationContent)
            // swiftlint:enable force_cast
        } catch {
            contentHandler(bestAttemptContent)
            print("Unable to load data: \(error)")
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        guard let contentHandler, let bestAttemptContent else { return }
        contentHandler(bestAttemptContent)
    }
}
