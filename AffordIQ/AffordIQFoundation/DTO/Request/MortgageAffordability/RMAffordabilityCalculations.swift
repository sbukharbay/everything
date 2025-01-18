//
//  RMAffordabilityCalculations.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 30/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMAffordabilityCalculations: Encodable {
    public let initialMonth: String
    
    public init(initialMonth: String) {
        self.initialMonth = initialMonth
    }
    
    enum CodingKeys: String, CodingKey {
        case initialMonth = "initial_month"
    }
}
