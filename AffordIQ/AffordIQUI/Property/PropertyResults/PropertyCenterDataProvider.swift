//
//  PropertyCenterDataProvider.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 26/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Combine
import UIKit

struct PropertyListings: Equatable, Hashable {
    let pageNumber: Int
    let pageSize: Int
    let response: PropertyListingsResponse?
}

enum PageStatus {
    case unknown
    case loading
    case loaded
}

/// A null completion handler, where this is to be ignored.
/// - Parameter completion: unused.
func noCompletion<T>(_: Subscribers.Completion<T>) where T: Error {
    // Unused
}

extension RMPropertyGoal {
    init?(listing: Listing) {
        guard let priceValue = listing.priceValue else {
            return nil
        }

        self.init(numberOfBedrooms: listing.numberOfBedrooms,
                  propertyPostalCode: listing.outcode,
                  propertyPostalTown: listing.postTown,
                  propertyType: listing.propertyType.isEmpty ? "Other" : listing.propertyType,
                  propertyValue: MonetaryAmount(amount: priceValue),
                  country: listing.country)
    }
}
