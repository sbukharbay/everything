//
//  UserDefaults+.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 05.01.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

public enum NotificationGroupName: String {
    case blackarrowgroup = "group.com.blackarrowgroup.affordiq"
    
    public var group: String { rawValue }
}

public enum StorageKey: String {
    case notificationCounter = "@storage.notification_counter"
    case notificationList = "@storage.notification_list"
    case reconsentSkipped = "@storage.reconsent_skipped"
    case isOnboardingCategorisationDone = "@storage.is_onboarding_categorisation_done"
    case notificationBadgeCount = "@storage.notification.badge_count"
    
    public var key: String { self.rawValue }
}

public extension UserDefaults {
    func string(forKey key: StorageKey) -> String? {
        string(forKey: key.rawValue)
    }
    
    func integer(forKey key: StorageKey) -> Int {
        integer(forKey: key.rawValue)
    }
    
    func object(forKey key: StorageKey) -> Any? {
        object(forKey: key.rawValue)
    }
    
    func bool(forKey key: StorageKey) -> Bool {
        bool(forKey: key.rawValue)
    }
    
    func data(forKey key: StorageKey) -> Data? {
        data(forKey: key.rawValue)
    }
}

public extension UserDefaults {
    func set(_ value: Any?, forKey key: StorageKey) {
        set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Int, forKey key: StorageKey) {
        set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Bool, forKey key: StorageKey) {
        set(value, forKey: key.rawValue)
    }
}
