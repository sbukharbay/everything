//
//  TopSpendingCategoriesResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct TopSpendingCategoriesResponse: Response {
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    public var topMonthlyAverageSpending: [TopAverageSpendingModel]
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case topMonthlyAverageSpending = "top_monthly_avg_spending"
    }
}

public struct TopAverageSpendingModel: Codable {
    public var categoryName: String
    public var categoryId: Int
    public let averageSpend: MonetaryAmount
    public var spendingGoal: MonetaryAmount?
    public var order: Int
    public var savedAmount = 0
    
    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case categoryId = "category_id"
        case averageSpend = "average_spend"
        case spendingGoal = "spending_goal"
        case order
    }
}
