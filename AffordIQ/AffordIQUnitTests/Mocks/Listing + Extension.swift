//
//  Listing + Extention.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 31.10.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

@testable import AffordIQFoundation

extension Listing {
    static func testListing() -> Self {
        Listing(agentAddress: "nil", agentLogo: nil, agentPhone: nil, availableFromDisplay: nil,
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
                status: .forSale, streetName: nil, thumbnailUrl: nil, internalEstimatedMonthsUntilAffordable: 2)
    }
}
