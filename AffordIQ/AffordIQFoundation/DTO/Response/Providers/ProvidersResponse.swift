//
//  ProvidersResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public typealias ProvidersResponse = [Provider]

public struct Provider: Decodable {
    public let displayName: String
    public let logoURL: String
    public let providerId: String
    public let scopes: [String]
    public let country: String
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case logoURL = "logo_url"
        case providerId = "provider_id"
        case scopes
        case country
    }
}

extension Provider: Hashable, Comparable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(providerId)
    }
    
    public static func < (lhs: Provider, rhs: Provider) -> Bool {
        return (lhs.displayName, lhs.providerId) < (rhs.displayName, rhs.providerId)
    }
}
