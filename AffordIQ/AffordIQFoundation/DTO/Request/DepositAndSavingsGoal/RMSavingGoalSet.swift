//
//  RMSavingGoalSet.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMSavingGoalSet: Encodable {
    public let monthlySavingsAmount: MonetaryAmount
    
    public init(monthlySavingsAmount: MonetaryAmount) {
        self.monthlySavingsAmount = monthlySavingsAmount
    }
    
    enum CodingKeys: String, CodingKey {
        case monthlySavingsAmount = "monthly_savings_amount"
    }
}
