//
//  AffordabilityCalculations.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AffordabilityCalculations: Codable {
    public let depositPercentage: Int
    public let containsValidResults: Bool
    public var homeCalculations: [MonthlyCalculations]
    public var selected = false
    
    enum CodingKeys: String, CodingKey {
        case depositPercentage = "percentage"
        case containsValidResults = "contains_valid_results"
        case homeCalculations = "calculations"
    }
}
