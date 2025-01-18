//
//  AllGoalsResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AllGoalsResponse: Response {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int
    public let spendingGoal: SpendingGoal?
    public let savingsGoal: SavingsGoal?
    public let propertyGoal: PropertyGoal?
    public let depositGoal: DepositGoal?
    public let monthesUntilPurchase: MonthsUntilPurchaseGoal?
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case spendingGoal = "overall_spending_goal"
        case savingsGoal = "savings_goal"
        case propertyGoal = "property_goal"
        case depositGoal = "deposit_goal"
        case monthesUntilPurchase = "months_until_purchase_goal"
    }
}
