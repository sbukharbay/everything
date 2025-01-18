//
//  AccountBalance.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AccountBalance: Codable, Equatable {
    public let currentBalance: MonetaryAmount
    public let availableBalanceIncludingOverdraft: MonetaryAmount
    public let overdraft: MonetaryAmount
    public let lastUpdated: Date?
    
    enum CodingKeys: String, CodingKey {
        case currentBalance = "current_balance"
        case availableBalanceIncludingOverdraft = "available_balance_including_overdraft"
        case overdraft
        case lastUpdated = "last_updated_date_time"
    }
}
