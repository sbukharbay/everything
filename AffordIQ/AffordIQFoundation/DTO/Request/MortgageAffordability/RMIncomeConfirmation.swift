//
//  RMIncomeConfirmation.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 19/04/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMIncomeConfirmation: Encodable {
    public let employmentStatus: String
    public let annualGrossSalary: MonetaryAmount?
    public let annualBonusPayments: MonetaryAmount?
    public let monthlyNetSalary: MonetaryAmount?
    // self employed
    public let earningsAfterTax: MonetaryAmount?
    public let incomeBeforeTax: MonetaryAmount?
    public let profitsAfterTax: MonetaryAmount?
    public let profitsBeforeTax: MonetaryAmount?
    public let numberOfMonths: Int?
    public let selfEmploymentType: SelfEmploymentType?
    
    public init(employmentStatus: String,
                annualGrossSalary: MonetaryAmount? = nil,
                annualBonusPayments: MonetaryAmount? = nil,
                monthlyNetSalary: MonetaryAmount? = nil,
                earningsAfterTax: MonetaryAmount? = nil,
                incomeBeforeTax: MonetaryAmount? = nil,
                profitsAfterTax: MonetaryAmount? = nil,
                profitsBeforeTax: MonetaryAmount? = nil,
                numberOfMonths: Int? = nil,
                selfEmploymentType: SelfEmploymentType? = nil) {
        self.employmentStatus = employmentStatus
        self.annualGrossSalary = annualGrossSalary
        self.annualBonusPayments = annualBonusPayments
        self.monthlyNetSalary = monthlyNetSalary
        self.earningsAfterTax = earningsAfterTax
        self.incomeBeforeTax = incomeBeforeTax
        self.profitsAfterTax = profitsAfterTax
        self.profitsBeforeTax = profitsBeforeTax
        self.numberOfMonths = numberOfMonths
        self.selfEmploymentType = selfEmploymentType
    }
    
    enum CodingKeys: String, CodingKey {
        case employmentStatus = "employment_status"
        case annualGrossSalary = "annual_gross_salary"
        case annualBonusPayments = "annual_bonus_payments"
        case monthlyNetSalary = "monthly_net_salary"
        case earningsAfterTax = "earnings_after_tax"
        case incomeBeforeTax = "income_before_tax"
        case profitsAfterTax = "profits_after_tax"
        case profitsBeforeTax = "profits_before_tax"
        case numberOfMonths = "number_of_months"
        case selfEmploymentType = "self_employment_type"
    }
}
