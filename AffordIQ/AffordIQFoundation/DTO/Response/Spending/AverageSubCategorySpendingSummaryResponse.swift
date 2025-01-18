//
//  AverageSubCategorySpendingSummaryResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AverageSubCategorySpendingSummaryResponse: Response {
    public var parentCategorySpendingSummary: CategorisedTransactionsSummariesModel
    public var subCategorisedSpendingSummaries: [SubCategorisedSpendingSummariesModel]
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    public var userId: String?
    
    enum CodingKeys: String, CodingKey {
        case parentCategorySpendingSummary = "parent_category_spending_summary"
        case subCategorisedSpendingSummaries = "sub_categorised_spending_summaries"
        case description
        case errors
        case message
        case statusCode = "status_code"
        case userId = "user_id"
    }
    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.parentCategorySpendingSummary = try container.decode(CategorisedTransactionsSummariesModel.self, forKey: .parentCategorySpendingSummary)
//        self.subCategorisedSpendingSummaries = try container.decodeIfPresent([SubCategorisedSpendingSummariesModel].self, forKey: .subCategorisedSpendingSummaries) ?? []
//        self.description = try container.decodeIfPresent(String.self, forKey: .description)
//        self.errors = try container.decodeIfPresent([String].self, forKey: .errors)
//        self.message = try container.decodeIfPresent(String.self, forKey: .message)
//        self.statusCode = try container.decode(Int.self, forKey: .statusCode)
//        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
//    }
}

public struct SubCategorisedSpendingSummariesModel: Codable {
    public var categoryId: Int
    public var categoryName: String
    public var averageValue: MonetaryAmount
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
        case averageValue = "average_value"
    }
}
