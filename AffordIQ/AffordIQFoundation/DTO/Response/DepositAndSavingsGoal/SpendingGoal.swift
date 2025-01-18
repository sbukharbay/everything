//
//  SpendingGoal.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct SpendingGoal: Decodable {
    enum CodingKeys: String, CodingKey {
        case monthlySpendingTarget = "monthly_spending_target"
    }
    
    public let monthlySpendingTarget: MonetaryAmount
}
