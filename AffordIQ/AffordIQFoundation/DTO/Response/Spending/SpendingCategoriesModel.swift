//
//  SpendingCategoriesModel.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct SpendingCategoriesModel: Codable {
    public let categoryId: Int
    public let categoryName: String
    public var childCategory: [ChildCategoriesModel]
    
    public var icon: String {
        return getIconName(categoryName)
    }
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
        case childCategory = "child_categories"
    }
}

public struct ChildCategoriesModel: Codable {
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
    }
    
    public let categoryId: Int
    public let categoryName: String
    
    public init(id: Int, name: String) {
        categoryId = id
        categoryName = name
    }
}
