//
//  RMPropertyGoal.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbayv on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMPropertyGoal: Encodable {
    public let numberOfBedrooms: Int?
    public let propertyPostalCode: String?
    public let propertyPostalTown: String?
    public let propertyType: String?
    public let propertyValue: MonetaryAmount
    public let country: String?
    
    public init(numberOfBedrooms: Int? = nil, propertyPostalCode: String? = nil, propertyPostalTown: String? = nil, propertyType: String? = nil, propertyValue: MonetaryAmount, country: String? = nil) {
        self.numberOfBedrooms = numberOfBedrooms
        self.propertyPostalCode = propertyPostalCode
        self.propertyPostalTown = propertyPostalTown
        self.propertyType = propertyType
        self.propertyValue = propertyValue
        self.country = country
    }
    
    enum CodingKeys: String, CodingKey {
        case numberOfBedrooms = "num_of_bedrooms"
        case propertyPostalCode = "property_postal_code"
        case propertyPostalTown = "property_postal_town"
        case propertyType = "property_type"
        case propertyValue = "property_value"
        case country
    }
}
