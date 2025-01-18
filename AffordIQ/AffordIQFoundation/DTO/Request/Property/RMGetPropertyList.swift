//
//  RMGetPropertyList.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMGetPropertyList: Encodable {
    public var bedrooms: Int?
    public var price: Decimal
    public var pageNumber: Int
    public var pageSize: Int
    public var area: String
    public var propertyType: String?
    public var userId: String
    
    public init(bedrooms: Int?, price: Decimal, pageNumber: Int, pageSize: Int, area: String, propertyType: String?, userId: String) {
        self.bedrooms = bedrooms
        self.price = price
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.area = area
        self.propertyType = propertyType
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case bedrooms = "minimum_beds"
        case price = "maximum_price"
        case pageNumber = "page_number"
        case pageSize = "page_size"
        case area
        case propertyType = "property_type"
        case userId = "user_id"
    }
}

extension RMGetPropertyList: Equatable {
    public static func == (lhs: RMGetPropertyList, rhs: RMGetPropertyList) -> Bool {
        lhs.bedrooms == rhs.bedrooms
        && lhs.price == rhs.price
        && lhs.pageSize == rhs.pageSize
        && lhs.area == rhs.area
        && lhs.propertyType == rhs.propertyType
    }
}
