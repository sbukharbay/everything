//
//  MonthlyBudgetDetailsResponse.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct MonthlyBudgetDetailsResponse: Response {
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public let statusCode: Int
    public let discretionary: DiscretionaryMonthlyBudgetResponse
    public let nonDiscretionary: NonDiscretionaryMonthlyBudgetResponse
    public let totalSpend: MonetaryAmount
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case discretionary
        case nonDiscretionary = "non_discretionary"
        case totalSpend = "total_spend"
    }
}

extension MonthlyBudgetDetailsResponse: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.statusCode == rhs.statusCode
        && lhs.discretionary == rhs.discretionary
        && lhs.nonDiscretionary == rhs.nonDiscretionary
        && lhs.totalSpend == rhs.totalSpend
    }
}
