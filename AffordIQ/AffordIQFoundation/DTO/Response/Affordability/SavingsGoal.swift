//
//  SavingsGoal.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct SavingsGoal: Decodable, Equatable, Hashable {
    public let monthlySavingsAmount: MonetaryAmount?
    
    enum CodingKeys: String, CodingKey {
        case monthlySavingsAmount = "monthly_savings_amount"
    }
}
