//
//  MortgageGoal.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct MortgageGoal: Decodable, Equatable {
    public let annualInterest: Decimal?
    public let loanToIncome: Decimal?
    public let loanToValue: Decimal?
    public let mortgageDurationYears: Int?
    public let monthlyPayment: MonetaryAmount?
    
    enum CodingKeys: String, CodingKey {
        case annualInterest = "annual_interest"
        case loanToIncome = "loan_to_income"
        case loanToValue = "loan_to_value"
        case mortgageDurationYears = "mortgage_duration_years"
        case monthlyPayment = "monthly_payment"
    }
}
