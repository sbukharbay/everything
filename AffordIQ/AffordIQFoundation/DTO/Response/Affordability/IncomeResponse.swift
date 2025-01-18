//
//  IncomeResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct IncomeResponse: Response, Equatable, Hashable {
    public let description: String?
    public let errors: [String]?
    public let estimated: Bool
    public let grossAnnualIncome: MonetaryAmount
    public let message: String?
    public let statusCode: Int
    
    public init(grossAnnualIncome: MonetaryAmount) {
        self.grossAnnualIncome = grossAnnualIncome
        description = nil
        errors = nil
        estimated = true
        message = nil
        statusCode = 200
    }
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case estimated
        case grossAnnualIncome = "gross_annual_income"
        case message
        case statusCode = "status_code"
    }
}
