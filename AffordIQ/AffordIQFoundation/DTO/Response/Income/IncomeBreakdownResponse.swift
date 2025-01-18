//
//  IncomeBreakdownResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct IncomeBreakdownResponse: Response {
    public let employmentStatus: EmploymentStatusType
    public let annualGrossSalary: MonetaryAmount?
    public let annualBonusPayments: MonetaryAmount?
    public let monthlyNetSalary: MonetaryAmount?
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    // self employed
    public let earningsAfterTax: MonetaryAmount?
    public let incomeBeforeTax: MonetaryAmount?
    public let profitsAfterTax: MonetaryAmount?
    public let profitsBeforeTax: MonetaryAmount?
    public let numberOfMonths: Int?
    public let selfEmploymentType: SelfEmploymentType?
    
    enum CodingKeys: String, CodingKey {
        case employmentStatus = "employment_status"
        case annualGrossSalary = "annual_gross_salary"
        case annualBonusPayments = "annual_bonus_payments"
        case monthlyNetSalary = "monthly_net_salary"
        case description
        case errors
        case message
        case statusCode = "status_code"
        case earningsAfterTax = "earnings_after_tax"
        case incomeBeforeTax = "income_before_tax"
        case profitsAfterTax = "profits_after_tax"
        case profitsBeforeTax = "profits_before_tax"
        case numberOfMonths = "number_of_months"
        case selfEmploymentType = "self_employment_type"
    }
}

public enum EmploymentStatusType: String, Codable {
    case employed = "EMPLOYED"
    case selfEmployed = "SELF_EMPLOYED"
    case both = "EMPLOYED_AND_SELF_EMPLOYED"
    case unemployed = "UNEMPLOYED"
    
    public func getText() -> String {
        switch self {
        case .employed:
            return "Employed"
        case .selfEmployed:
            return "Self-Employed"
        case .both:
            return "Employed & Self-Employed"
        case .unemployed:
            return "Unemployed"
        }
    }
}
