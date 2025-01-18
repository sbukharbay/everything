//
//  PropertyGoal.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct PropertyGoal: Decodable, Equatable {
    public let numberOfBedrooms: Int?
    public let propertyPostalCode: String?
    public let propertyPostalTown: String?
    public let propertyType: String?
    public let propertyValue: MonetaryAmount?
    
    enum CodingKeys: String, CodingKey {
        case numberOfBedrooms = "num_of_bedrooms"
        case propertyPostalCode = "property_postal_code"
        case propertyPostalTown = "property_postal_town"
        case propertyType = "property_type"
        case propertyValue = "property_value"
    }
}
