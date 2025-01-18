//
//  AverageSpendingSummaryResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AverageSpendingSummaryResponse: Response {
    public var monthlyAverage: MonetaryAmount
    public var averageCategorisedTransactions: [AverageCategorisedTransactionsModel]
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    public var userId: String?
    
    enum CodingKeys: String, CodingKey {
        case monthlyAverage = "monthly_average"
        case averageCategorisedTransactions = "average_categorised_transactions"
        case description
        case errors
        case message
        case statusCode = "status_code"
        case userId = "user_id"
    }
}

public struct AverageCategorisedTransactionsModel: Codable {
    public var categorisedTransactionsType: String
    public var categorisedTransactionsSummaries: [CategorisedTransactionsSummariesModel]
    
    enum CodingKeys: String, CodingKey {
        case categorisedTransactionsType = "categorised_transactions_type"
        case categorisedTransactionsSummaries = "categorised_transactions_summaries"
    }
}

public struct CategorisedTransactionsSummariesModel: Codable {
    public var categoryId: Int
    public var categoryName: String
    public var averageValue: MonetaryAmount
    
    public var icon: String {
        return getIconName(categoryName)
    }
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
        case averageValue = "average_value"
    }
}
