//
//  DiscretionaryMonthlyBudgetResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct DiscretionaryMonthlyBudgetResponse: Codable, Equatable {
    public let targetSpend: MonetaryAmount
    public let leftToSpend: MonetaryAmount
    public let pattern: MonthlyBudgetPattern
    
    enum CodingKeys: String, CodingKey {
        case targetSpend = "target_spend"
        case leftToSpend = "left_to_spend"
        case pattern
    }
}

public enum MonthlyBudgetPattern: String, Codable {
    case meet = "MEET"
    case `break` = "BREAK"
    case exceeded = "EXCEEDED"
}
