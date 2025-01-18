//
//  NonDiscretionaryMonthlyBudgetResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct NonDiscretionaryMonthlyBudgetResponse: Codable, Equatable {
    public let averageSpend: MonetaryAmount
    public let currentSpend: MonetaryAmount
    
    enum CodingKeys: String, CodingKey {
        case averageSpend = "average_spend"
        case currentSpend = "current_spend"
    }
}
