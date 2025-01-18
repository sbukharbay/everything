//
//  MonthsUntilPurchaseGoal.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct MonthsUntilPurchaseGoal: Decodable {
    enum CodingKeys: String, CodingKey {
        case targetMonths = "target_months"
    }
    
    public let targetMonths: Int
}
