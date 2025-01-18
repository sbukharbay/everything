//
//  MonthlyBreakdownResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct MonthlyBreakdownResponse: Response {
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public let statusCode: Int
    public let discretionary: [SpendingBreakdownCategory]
    public let nonDiscretionary: [SpendingBreakdownCategory]
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case discretionary = "discretionary_spending"
        case nonDiscretionary = "non_discretionary_spending"
    }
}

public struct SpendingBreakdownCategory: Codable {
    public let order: Int
    public let id: Int
    public let name: String
    public let actualSpend: MonetaryAmount
    public var spendingGoal: MonetaryAmount?
    public var monthlyAverage: MonetaryAmount
    public let parentCategoryName: String?
    public let spendGoalPercentage: Decimal?
    
    public var icon: String {
        return getIconName(parentCategoryName ?? name)
    }
    
    enum CodingKeys: String, CodingKey {
        case order
        case id = "category_id"
        case name = "category_name"
        case actualSpend = "actual_spend"
        case spendingGoal = "spending_goal"
        case parentCategoryName = "parent_category_name"
        case spendGoalPercentage = "spend_as_percentage_of_goal"
        case monthlyAverage = "monthly_average"
    }
}
