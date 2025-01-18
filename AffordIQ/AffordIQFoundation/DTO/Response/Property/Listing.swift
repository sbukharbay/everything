//
//  Listing.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct Listing: Decodable, Equatable, Hashable {
    public let agentAddress: String?
    public let agentLogo: String?
    public let agentPhone: String?
    public let availableFromDisplay: String?
    public let billsIncluded: Int?
    public let category: String?
    public let country: String?
    public let countryCode: String?
    public let county: String?
    public let listingDescription: String?
    public let detailsUrl: String
    public let displayableAddress: String?
    public let firstPublishedDate: String?
    public let floorArea: FloorArea?
    public let floorPlan: [String]?
    public let furnishedState: String?
    public let image150x113Url: String?
    public let image354x255Url: String?
    public let image50x38Url: String?
    public let image645x430Url: String?
    public let image80x60Url: String?
    public let imageCaption: String?
    public let imageUrl: String
    public let lastPublishedDate: String?
    public let latitude: Double?
    public let lettingFees: String?
    public let listingId: String?
    public let listingStatus: String?
    public let locationIsApproximate: Int?
    public let longitude: Double?
    public let newHome: String?
    public let numberOfBathrooms: Int?
    public let numberOfBedrooms: Int
    public let numberOfFloors: Int?
    public let numberOfReceptionRooms: Int?
    public let outcode: String?
    public let petsAllowed: Int?
    public let postTown: String?
    public let price: String?
    public let priceChange: [PriceChange]?
    public let priceChangeSummary: PriceChangeSummary?
    public let priceModifier: String?
    public let propertyType: String
    public let rentalPrices: RentalPrice?
    public let shortDescription: String?
    public let status: ListingStatus
    public let streetName: String?
    public let thumbnailUrl: String?
    public let internalEstimatedMonthsUntilAffordable: Int
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.listingId == rhs.listingId
    }
    
    public var priceValue: Decimal? {
        return NumberFormatters.from(price)
    }
    
    enum CodingKeys: String, CodingKey {
        case agentAddress = "agent_address"
        case agentLogo = "agent_logo"
        case agentPhone = "agent_phone"
        case availableFromDisplay = "available_from_display"
        case billsIncluded = "bills_included"
        case category
        case country
        case countryCode = "country_code"
        case county
        case listingDescription = "description"
        case detailsUrl = "details_url"
        case displayableAddress = "displayable_address"
        case firstPublishedDate = "first_published_date"
        case floorArea = "floor_area"
        case floorPlan = "floor_plan"
        case furnishedState = "furnished_state"
        case image150x113Url = "image_150_113_url"
        case image354x255Url = "image_354_255_url"
        case image50x38Url = "image_50_38_url"
        case image645x430Url = "image_645_430_url"
        case image80x60Url = "image_80_60_url"
        case imageCaption = "image_caption"
        case imageUrl = "image_url"
        case lastPublishedDate = "last_published_date"
        case latitude
        case lettingFees = "letting_fees"
        case listingId = "listing_id"
        case listingStatus = "listing_status"
        case locationIsApproximate = "location_is_approximate"
        case longitude
        case newHome = "new_home"
        case numberOfBathrooms = "num_bathrooms"
        case numberOfBedrooms = "num_bedrooms"
        case numberOfFloors = "num_floors"
        case numberOfReceptionRooms = "num_recepts"
        case outcode
        case petsAllowed = "pets_allowed"
        case postTown = "post_town"
        case price
        case priceChange = "price_change"
        case priceChangeSummary = "price_change_summary"
        case priceModifier = "price_modifier"
        case propertyType = "property_type"
        case rentalPrices = "rental_prices"
        case shortDescription = "short_description"
        case status
        case streetName = "street_name"
        case thumbnailUrl = "thumbnail_url"
        case internalEstimatedMonthsUntilAffordable = "est_months_till_affordable"
    }
}

public struct FloorArea: Decodable, Equatable, Hashable {
    public let maxFloorArea: UnitMeasurement?
    public let minFloorArea: UnitMeasurement?
    
    enum CodingKeys: String, CodingKey {
        case maxFloorArea = "max_floor_area"
        case minFloorArea = "min_floor_area"
    }
}

public struct PriceChange: Decodable, Equatable, Hashable {
    public let date: String
    public let direction: String
    public let percent: String
    public let price: Double
}

public struct PriceChangeSummary: Decodable, Equatable, Hashable {
    public let direction: String
    public let lastUpdatedDate: String
    public let percent: String
    
    enum CodingKeys: String, CodingKey {
        case direction
        case lastUpdatedDate = "last_updated_date"
        case percent
    }
}

public struct RentalPrice: Decodable, Equatable, Hashable {
    public let accurate: String
    public let perMonth: Decimal
    public let perWeek: Decimal
    public let sharedOccupancy: String
    
    enum CodingKeys: String, CodingKey {
        case accurate
        case perMonth = "per_month"
        case perWeek = "per_week"
        case sharedOccupancy = "shared_occupancy"
    }
}

public enum ListingStatus: String, Codable {
    case forSale = "for_sale"
    case saleUnderOffer = "sale_under_offer"
    case sold
    case toRent = "to_rent"
    case rentUnderOffer = "rent_under_offer"
    case rented
    
    public static let saleStatusValues: Set<ListingStatus> = [.forSale, .saleUnderOffer, .sold]
    public static let rentalStatusValues: Set<ListingStatus> = [.toRent, .rentUnderOffer, .rented]
}
