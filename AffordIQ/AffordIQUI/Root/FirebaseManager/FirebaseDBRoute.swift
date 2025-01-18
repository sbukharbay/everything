//
//  FirebaseDBRoutes.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 22/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

enum FirebaseDBRoute {
    case maintenanceMode
    case maintenanceHeader
    case maintenanceTXT1
    case maintenanceTXT2
    
    var url: String {
        switch self {
        case .maintenanceMode:
            return "maintenance/affordiq_maintenance_mode_ios"
        case .maintenanceHeader:
            return "maintenance/affordiq_maintenance_header"
        case .maintenanceTXT1:
            return "maintenance/affordiq_maintenance_txt_1"
        case .maintenanceTXT2:
            return "maintenance/affordiq_maintenance_txt_2"
        }
    }
}
