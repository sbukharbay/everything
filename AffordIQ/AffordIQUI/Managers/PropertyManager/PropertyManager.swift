//
//  PropertyManager.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 26/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQNetworkKit
import AffordIQFoundation

class PropertyManager {
    static var shared = PropertyManager()
    
    var propertySearchParameters: RMGetPropertyList? {
        didSet {
            if oldValue != propertySearchParameters {
                propertyListings = nil
            }
        }
    }
    var pageNumber: Int = 1
    var propertyListings: PropertyListingsResponse?
}
