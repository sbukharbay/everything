//
//  PropertyRouter.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 14.04.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum PropertyRouter: RequestConvertible {
    case getAutocomplete(searchTerm: String)
    case getListings(model: RMGetPropertyList)
    
    public var path: String {
        switch self {
        case .getAutocomplete:
            return "/api/property/geo/autocomplete"
        case .getListings:
            return "/api/property/listings"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getAutocomplete:
            return .get
        case  .getListings:
            return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .getAutocomplete(let model):
            return ["search_term": model]
        case .getListings:
            return nil
        }
    }
    
    public var body: Body? {
        switch self {
        case .getListings(let model):
            return model.asJson
        default: return nil
        }
    }
}
