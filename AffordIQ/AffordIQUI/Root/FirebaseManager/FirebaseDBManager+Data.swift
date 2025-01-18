//
//  FirebaseRCManager+Data.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 20/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public extension FirebaseDBManager {
    var isInMaintenanceMode: Bool {
        get async {
            let data = await getDataFromFirebaseDB(with: FirebaseDBRoute.maintenanceMode.url)
            return data?.value as? Bool ?? false
        }
    }
    
    var maintenanceHeader: String {
        get async {
            let data = await getDataFromFirebaseDB(with: FirebaseDBRoute.maintenanceHeader.url)
            return data?.value as? String ?? "UNDER MAINTENANCE"
        }
    }
    
    var maintenanceTXT1: String {
        get async {
            let data = await getDataFromFirebaseDB(with: FirebaseDBRoute.maintenanceTXT1.url)
            return data?.value as? String ?? "affordIQ is currently undergoing maintenance."
        }
    }
    
    var maintenanceTXT2: String {
        get async {
            let data = await getDataFromFirebaseDB(with: FirebaseDBRoute.maintenanceTXT2.url)
            return data?.value as? String ?? "We'll be back soon."
        }
    }
}
