//
//  MortgageLimits.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct MortgageLimits: Decodable, Equatable {
    public let currentAffordability: MonetaryAmount
    public let currentDeposit: MonetaryAmount
    public let maximumPossibleMortgage: MonetaryAmount
    public let currentExternalCapital: MonetaryAmount
    public let repaymentCapacity: MonetaryAmount
    
    enum CodingKeys: String, CodingKey {
        case currentAffordability = "current_affordability"
        case currentDeposit = "current_deposit"
        case maximumPossibleMortgage = "maximum_possible_mortgage"
        case currentExternalCapital = "current_external_capital_item"
        case repaymentCapacity = "repayment_capacity"
    }
}
