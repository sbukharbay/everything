//
//  RMDepositGoal.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 29/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMDepositGoal: Encodable {
    enum CodingKeys: String, CodingKey {
        case loanToValue = "loan_to_value"
    }
    
    public let loanToValue: Float
    
    public init(loanToValue: Float) {
        self.loanToValue = loanToValue
    }
}
