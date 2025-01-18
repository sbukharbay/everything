//
//  GeneralPreferences.swift
//  AffordIQ
//
//  Created by Sultangazy Bukharbay on 12/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation

public final class GeneralPreferences {
    public static let shared = GeneralPreferences()
    private let database: UserDefaults
    
    private init() {
        database = UserDefaults.standard
        database.register(defaults: [
            StorageKey.notificationCounter.key: 0,
            StorageKey.isOnboardingCategorisationDone.key: false
        ])
    }
    
    public var notificationCounter: Int {
        get { database.integer(forKey: .notificationCounter) }
        set { database.set(newValue, forKey: .notificationCounter) }
    }
    
    public var notificationList: Data? {
        get { database.data(forKey: .notificationList) }
        set { database.set(newValue, forKey: .notificationList) }
    }
    
    public var isOnboardingCategorisationDone: Bool {
        get { database.bool(forKey: .isOnboardingCategorisationDone) }
        set { database.set(newValue, forKey: .isOnboardingCategorisationDone) }
    }
}
