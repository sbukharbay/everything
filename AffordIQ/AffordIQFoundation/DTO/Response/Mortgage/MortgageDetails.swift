//
//  MortgageDetails.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct MortgageDetails: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case mortgage
        case repayment
        case interestRate = "interest_rate"
        case term
    }
    
    public let mortgage: MonetaryAmount
    public var repayment: MonetaryAmount
    public var interestRate: Double
    public var term: Int
}
