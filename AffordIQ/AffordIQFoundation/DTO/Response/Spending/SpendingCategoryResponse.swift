//
//  SpendingCategoryResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct SpendingCategoryResponse: Response {
    public var spendingCategories: [SpendingCategoriesModel]
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case spendingCategories = "spending_categories"
        case description
        case errors
        case message
        case statusCode = "status_code"
    }
}
