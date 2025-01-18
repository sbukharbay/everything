//
//  AffordabilityPreviewModel.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AffordabilityPreviewModel: Codable {
    public let depositPercentage: Float
    public let monthsUntilAffordable: Int?
    public let targetDeposit: MonetaryAmount
    
    enum CodingKeys: String, CodingKey {
        case depositPercentage = "deposit_percentage"
        case monthsUntilAffordable = "months_until_affordable"
        case targetDeposit = "target_deposit"
    }
}
