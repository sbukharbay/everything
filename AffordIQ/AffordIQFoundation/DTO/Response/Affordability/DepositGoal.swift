//
//  DepositGoal.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct DepositGoal: Decodable, Equatable {
    public let id: Int?
    public let loanToValue: Decimal?
    public let parentGoalId: Int?
    public let state: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case loanToValue = "loan_to_value"
        case parentGoalId = "parent_goal_id"
        case state
    }
}
