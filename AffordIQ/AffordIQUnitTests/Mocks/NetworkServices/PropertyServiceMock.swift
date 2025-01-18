//
//  PropertyServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 11.10.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class PropertyServiceMock: PropertySource {
    var didDeviceRegister = false
    
    func getAutocomplete(searchTerm: String) async throws -> AutocompleteResponse {
        switch searchTerm {
        case "error":
            throw NetworkError.badURLRequest
        default:
            return AutocompleteResponse(suggestions: [Suggestion(value: "Glasgow")])
        }
    }
    
    func getListings(model: RMGetPropertyList) async throws -> PropertyListingsResponse {
        if model.area == "Error" {
            let error = NSError(domain: "429", code: 429)
            throw error
        }
        let listing = [Listing(agentAddress: nil, agentLogo: nil, agentPhone: nil, availableFromDisplay: nil,
                               billsIncluded: nil, category: nil, country: nil, countryCode: nil, county: nil,
                               listingDescription: nil, detailsUrl: "", displayableAddress: nil,
                               firstPublishedDate: nil, floorArea: nil, floorPlan: nil, furnishedState: nil,
                               image150x113Url: nil, image354x255Url: nil, image50x38Url: nil, image645x430Url: nil,
                               image80x60Url: nil, imageCaption: nil, imageUrl: "", lastPublishedDate: nil,
                               latitude: nil, lettingFees: nil, listingId: nil, listingStatus: nil,
                               locationIsApproximate: nil, longitude: nil, newHome: nil, numberOfBathrooms: nil,
                               numberOfBedrooms: 2, numberOfFloors: nil, numberOfReceptionRooms: nil, outcode: nil,
                               petsAllowed: nil, postTown: nil, price: "100000", priceChange: nil, priceChangeSummary: nil,
                               priceModifier: nil, propertyType: "", rentalPrices: nil, shortDescription: nil,
                               status: .forSale, streetName: nil, thumbnailUrl: nil, internalEstimatedMonthsUntilAffordable: 2),
                       Listing(agentAddress: nil, agentLogo: nil, agentPhone: nil, availableFromDisplay: nil,
                               billsIncluded: nil, category: nil, country: nil, countryCode: nil, county: nil,
                               listingDescription: nil, detailsUrl: "", displayableAddress: nil,
                               firstPublishedDate: nil, floorArea: nil, floorPlan: nil, furnishedState: nil,
                               image150x113Url: nil, image354x255Url: nil, image50x38Url: nil, image645x430Url: nil,
                               image80x60Url: nil, imageCaption: nil, imageUrl: "", lastPublishedDate: nil,
                               latitude: nil, lettingFees: nil, listingId: nil, listingStatus: nil,
                               locationIsApproximate: nil, longitude: nil, newHome: nil, numberOfBathrooms: nil,
                               numberOfBedrooms: 2, numberOfFloors: nil, numberOfReceptionRooms: nil, outcode: nil,
                               petsAllowed: nil, postTown: nil, price: "100000", priceChange: nil, priceChangeSummary: nil,
                               priceModifier: nil, propertyType: "", rentalPrices: nil, shortDescription: nil,
                               status: .forSale, streetName: nil, thumbnailUrl: nil, internalEstimatedMonthsUntilAffordable: 2),
                       Listing(agentAddress: nil, agentLogo: nil, agentPhone: nil, availableFromDisplay: nil,
                               billsIncluded: nil, category: nil, country: nil, countryCode: nil, county: nil,
                               listingDescription: nil, detailsUrl: "", displayableAddress: nil,
                               firstPublishedDate: nil, floorArea: nil, floorPlan: nil, furnishedState: nil,
                               image150x113Url: nil, image354x255Url: nil, image50x38Url: nil, image645x430Url: nil,
                               image80x60Url: nil, imageCaption: nil, imageUrl: "", lastPublishedDate: nil,
                               latitude: nil, lettingFees: nil, listingId: nil, listingStatus: nil,
                               locationIsApproximate: nil, longitude: nil, newHome: nil, numberOfBathrooms: nil,
                               numberOfBedrooms: 2, numberOfFloors: nil, numberOfReceptionRooms: nil, outcode: nil,
                               petsAllowed: nil, postTown: nil, price: "100000", priceChange: nil, priceChangeSummary: nil,
                               priceModifier: nil, propertyType: "", rentalPrices: nil, shortDescription: nil,
                               status: .forSale, streetName: nil, thumbnailUrl: nil, internalEstimatedMonthsUntilAffordable: 2)]
        return PropertyListingsResponse(areaName: "", boundingBox: nil, country: "", county: "", latitude: nil, listing: listing, longitude: nil, postcode: "", resultCount: 20, street: "", town: "")
    }
}
