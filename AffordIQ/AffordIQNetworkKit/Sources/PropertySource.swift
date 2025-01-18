//
//  PropertySource.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 14.04.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol PropertySource {
    func getAutocomplete(searchTerm: String) async throws -> AutocompleteResponse
    
    func getListings(model: RMGetPropertyList) async throws -> PropertyListingsResponse
}

public final class PropertyService: AdaptableNetwork<PropertyRouter>, PropertySource {
    public func getAutocomplete(searchTerm: String) async throws -> AutocompleteResponse {
        try await queryRequest(AutocompleteResponse.self, from: .getAutocomplete(searchTerm: searchTerm))
    }
    
    public func getListings(model: RMGetPropertyList) async throws -> PropertyListingsResponse {
        try await request(PropertyListingsResponse.self, from: .getListings(model: model))
    }
}
