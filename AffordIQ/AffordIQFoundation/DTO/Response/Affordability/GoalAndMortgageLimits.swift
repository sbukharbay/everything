//
//  GoalAndMortgageLimits.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 06/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct GoalAndMortgageLimits: Decodable, Equatable {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let monthsUntilAffordable: Int?
    public let mortgageLimits: MortgageLimits?
    public let propertyGoal: PropertyGoal?
    public let mortgageGoal: MortgageGoal?
    public let targetDeposit: MonetaryAmount?
    public let savingsGoal: SavingsGoal?
    public let statusCode: Int
    public let userId: String
    public let fees: MonetaryAmount?
    public let depositGoal: DepositGoal?
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case monthsUntilAffordable = "months_until_affordable"
        case mortgageLimits = "mortgage_limits"
        case propertyGoal = "property_goal"
        case mortgageGoal = "mortgage_goal"
        case targetDeposit = "target_deposit"
        case savingsGoal = "savings_goal"
        case statusCode = "status_code"
        case userId = "user_id"
        case fees = "fees_and_cost"
        case depositGoal = "deposit_goal"
    }
}
