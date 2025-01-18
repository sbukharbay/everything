//
//  UNNotificationAttachment+Extension.swift
//  NotificationServiceExtension
//
//  Created by Sultangazy Bukharbay on 03/11/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import UserNotifications

extension UNNotificationAttachment {
    static func download(
        imageFileIdentifier: String,
        data: Data,
        options: [NSObject: AnyObject]?
    ) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.blackarrowgroup.affordiq") {
            do {
                let newDirectory = directory.appendingPathComponent("Images")
                if !fileManager.fileExists(atPath: newDirectory.path) {
                    try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
                }
                let fileURL = newDirectory.appendingPathComponent(imageFileIdentifier)
                do {
                    try data.write(to: fileURL, options: [])
                } catch {
                    print("Unable to load data: \(error)")
                }
                let pref = UserDefaults(suiteName: "group.com.blackarrowgroup.affordiq")
                pref?.set(data, forKey: "NOTIF_IMAGE")
                pref?.synchronize()
                let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL, options: options)
                return imageAttachment
            } catch let error {
                print("Error: \(error)")
            }
        }
        
        return nil
    }
}
