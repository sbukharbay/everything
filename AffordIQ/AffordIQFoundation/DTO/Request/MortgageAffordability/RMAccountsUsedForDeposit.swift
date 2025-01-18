//
//  RMAccountsUsedForDeposit.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMAccountsUsedForDeposit: Encodable {
    public let contributesToDeposit: [String]
    public let doesNotContributeToDeposit: [String]
    public let userID: String
    
    public init(contributesToDeposit: [String], doesNotContributeToDeposit: [String], userID: String) {
        self.contributesToDeposit = contributesToDeposit
        self.doesNotContributeToDeposit = doesNotContributeToDeposit
        self.userID = userID
    }
    
    enum CodingKeys: String, CodingKey {
        case contributesToDeposit = "contributes_to_deposit"
        case doesNotContributeToDeposit = "does_not_contribute_to_deposit"
        case userID = "user_id"
    }
}
