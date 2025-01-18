//
//  PropertyListingsResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct PropertyListingsResponse: Decodable, Equatable, Hashable {
    public let areaName: String?
    public let boundingBox: BoundingBox?
    public let country: String?
    public let county: String?
    public let latitude: Double?
    public let listing: [Listing]
    public let longitude: Double?
    public let postcode: String?
    public let resultCount: Int
    public let street: String?
    public let town: String?
    
    enum CodingKeys: String, CodingKey {
        case areaName = "area_name"
        case boundingBox = "bounding_box"
        case country
        case county
        case latitude
        case listing
        case longitude
        case postcode
        case resultCount = "result_count"
        case street
        case town
    }
}

public extension PropertyListingsResponse {
    static var maximumAffordabilityMonthsInt = 36
    
    static var maximumAffordabilityMonths: Float { Float(maximumAffordabilityMonthsInt) }
}

public struct UnitMeasurement: Decodable, Equatable, Hashable {
    public let units: String
    public let value: String
}

public struct BoundingBox: Decodable, Equatable, Hashable {
    public let latitudeMax: String
    public let latitudeMin: String
    public let longitudeMax: String
    public let longitudeMin: String
    
    enum CodingKeys: String, CodingKey {
        case latitudeMax = "latitude_max"
        case latitudeMin = "latitude_min"
        case longitudeMax = "longitude_max"
        case longitudeMin = "longitude_min"
    }
}
