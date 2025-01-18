//
//  MonthlyCalculations.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct MonthlyCalculations: Codable {
    public let monthlyPeriod: Int
    public let depositValue: MonetaryAmount
    public let homeValue: MonetaryAmount
    public let fees: MonetaryAmount
    public let valid: Bool
    public var isSelected = false
    
    enum CodingKeys: String, CodingKey {
        case monthlyPeriod = "monthly_period"
        case depositValue = "deposit_value"
        case homeValue = "home_value"
        case fees
        case valid
    }
}
