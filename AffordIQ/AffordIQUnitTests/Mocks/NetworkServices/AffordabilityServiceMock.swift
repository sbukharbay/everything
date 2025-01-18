//
//  AffordabilityServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 17/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class AffordabilityServiceMock: AffordabilitySource {
    func getMortgageDetails(
        userID: String,
        depositAbsoluteValue: String,
        propertyValue: String
    ) async throws -> MortgageDetailsResponse {
        if userID == "error" {
            throw NetworkError.unauthorized
        } else {
            return MortgageDetailsResponse(description: "", errors: [], message: "", statusCode: 200, mortgageDetails: MortgageDetails(mortgage: MonetaryAmount(amount: 100), repayment: MonetaryAmount(amount: 100), interestRate: 4, term: 12))
        }
    }
    
    func getGoalTrackingAndMortgageLimits(
        userID: String
    ) async throws -> PropertyGoalAndMortgageLimitsResponse {
        if userID == "work" {
            return PropertyGoalAndMortgageLimitsResponse(description: "",
                                                         errors: [],
                                                         message: "",
                                                         monthsUntilAffordable: 12,
                                                         mortgageLimits: nil,
                                                         propertyGoal: nil,
                                                         mortgageGoal: nil,
                                                         targetDeposit: nil,
                                                         savingsGoal: nil,
                                                         statusCode: 200,
                                                         userId: userID,
                                                         fees: nil,
                                                         depositGoal: nil)
        } else if userID == "workNil"{
            return PropertyGoalAndMortgageLimitsResponse(description: "",
                                                         errors: [],
                                                         message: "",
                                                         monthsUntilAffordable: nil,
                                                         mortgageLimits: nil,
                                                         propertyGoal: nil,
                                                         mortgageGoal: nil,
                                                         targetDeposit: nil,
                                                         savingsGoal: nil,
                                                         statusCode: 200,
                                                         userId: userID,
                                                         fees: nil,
                                                         depositGoal: nil)
        } else {
            throw NetworkError.badID
        }
    }
    
    func getAffordabilityCalculations(
        userID: String, model: RMAffordabilityCalculations?
    ) async throws -> AffordabilityCalculationsResponse {
        switch userID {
        case "userID":
            let home1 = [MonthlyCalculations(monthlyPeriod: 0,
                                             depositValue: MonetaryAmount(amount: 10000.0),
                                             homeValue: MonetaryAmount(amount: 100000.0),
                                             fees: MonetaryAmount(amount: 1000.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 3,
                                             depositValue: MonetaryAmount(amount: 11000.0),
                                             homeValue: MonetaryAmount(amount: 110000.0),
                                             fees: MonetaryAmount(amount: 1100.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 6,
                                             depositValue: MonetaryAmount(amount: 12000.0),
                                             homeValue: MonetaryAmount(amount: 120000.0),
                                             fees: MonetaryAmount(amount: 1200.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 12,
                                             depositValue: MonetaryAmount(amount: 13000.0),
                                             homeValue: MonetaryAmount(amount: 130000.0),
                                             fees: MonetaryAmount(amount: 1300.0),
                                             valid: false)]
            let home2 = [MonthlyCalculations(monthlyPeriod: 0,
                                             depositValue: MonetaryAmount(amount: 20000.0),
                                             homeValue: MonetaryAmount(amount: 200000.0),
                                             fees: MonetaryAmount(amount: 2000.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 3,
                                             depositValue: MonetaryAmount(amount: 21000.0),
                                             homeValue: MonetaryAmount(amount: 210000.0),
                                             fees: MonetaryAmount(amount: 2100.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 6,
                                             depositValue: MonetaryAmount(amount: 22000.0),
                                             homeValue: MonetaryAmount(amount: 220000.0),
                                             fees: MonetaryAmount(amount: 2200.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 12,
                                             depositValue: MonetaryAmount(amount: 23000.0),
                                             homeValue: MonetaryAmount(amount: 230000.0),
                                             fees: MonetaryAmount(amount: 2300.0),
                                             valid: false)]
            let home3 = [MonthlyCalculations(monthlyPeriod: 0,
                                             depositValue: MonetaryAmount(amount: 30000.0),
                                             homeValue: MonetaryAmount(amount: 300000.0),
                                             fees: MonetaryAmount(amount: 3000.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 3,
                                             depositValue: MonetaryAmount(amount: 31000.0),
                                             homeValue: MonetaryAmount(amount: 310000.0),
                                             fees: MonetaryAmount(amount: 3100.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 6,
                                             depositValue: MonetaryAmount(amount: 32000.0),
                                             homeValue: MonetaryAmount(amount: 320000.0),
                                             fees: MonetaryAmount(amount: 3200.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 12,
                                             depositValue: MonetaryAmount(amount: 33000.0),
                                             homeValue: MonetaryAmount(amount: 330000.0),
                                             fees: MonetaryAmount(amount: 3300.0),
                                             valid: false)]
            let home4 = [MonthlyCalculations(monthlyPeriod: 0,
                                             depositValue: MonetaryAmount(amount: 40000.0),
                                             homeValue: MonetaryAmount(amount: 400000.0),
                                             fees: MonetaryAmount(amount: 4000.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 3,
                                             depositValue: MonetaryAmount(amount: 41000.0),
                                             homeValue: MonetaryAmount(amount: 410000.0),
                                             fees: MonetaryAmount(amount: 4100.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 6,
                                             depositValue: MonetaryAmount(amount: 42000.0),
                                             homeValue: MonetaryAmount(amount: 420000.0),
                                             fees: MonetaryAmount(amount: 4200.0),
                                             valid: true),
                         MonthlyCalculations(monthlyPeriod: 12,
                                             depositValue: MonetaryAmount(amount: 43000.0),
                                             homeValue: MonetaryAmount(amount: 430000.0),
                                             fees: MonetaryAmount(amount: 4300.0),
                                             valid: false)]
            let calculations = [AffordabilityCalculations(depositPercentage: 5,
                                                          containsValidResults: true,
                                                          homeCalculations: home1),
                                AffordabilityCalculations(depositPercentage: 10,
                                                          containsValidResults: true,
                                                          homeCalculations: home2),
                                AffordabilityCalculations(depositPercentage: 15,
                                                          containsValidResults: true,
                                                          homeCalculations: home3),
                                AffordabilityCalculations(depositPercentage: 20,
                                                          containsValidResults: false,
                                                          homeCalculations: home4)]
            return AffordabilityCalculationsResponse(description: nil, errors: nil, message: nil, statusCode: 200, affordabilityCalculations: calculations)
        default:
            throw NetworkError.unauthorized
        }
    }
    
    func getAffordabilityStatus(userID: String) async throws -> TransactionsStatus {
        throw NetworkError.unauthorized
    }
    
    func getAffordabilityPreview(userID: String) async throws -> AffordabilityPreviewResponse {
        if userID == "error" { throw NetworkError.badID }
        
        return AffordabilityPreviewResponse(
            affordabilityPreview: [
                AffordabilityPreviewModel(
                    depositPercentage: 10,
                    monthsUntilAffordable: 5,
                    targetDeposit: MonetaryAmount(amount: 10_000)
                )
            ],
            currentDeposit: MonetaryAmount(amount: 10),
            statusCode: 200)
    }
    
    func getIncomeStatus(userID: String) async throws -> IncomeBreakdownResponse {
        switch userID {
        case "employed":
            return IncomeBreakdownResponse(employmentStatus: .employed, 
                                           annualGrossSalary: MonetaryAmount(amount: 200000.0),
                                           annualBonusPayments: MonetaryAmount(amount: 100000.0),
                                           monthlyNetSalary: MonetaryAmount(amount: 15000.0),
                                           statusCode: 200,
                                           earningsAfterTax: nil,
                                           incomeBeforeTax: nil,
                                           profitsAfterTax: nil,
                                           profitsBeforeTax: nil,
                                           numberOfMonths: nil,
                                           selfEmploymentType: nil)
        case "selfEmployed":
            return IncomeBreakdownResponse(employmentStatus: .selfEmployed, 
                                           annualGrossSalary: nil,
                                           annualBonusPayments: nil,
                                           monthlyNetSalary: nil,
                                           statusCode: 200,
                                           earningsAfterTax: MonetaryAmount(amount: 150000.0),
                                           incomeBeforeTax: MonetaryAmount(amount: 200000.0),
                                           profitsAfterTax: MonetaryAmount(amount: 150000.0),
                                           profitsBeforeTax: MonetaryAmount(amount: 200000.0),
                                           numberOfMonths: 26,
                                           selfEmploymentType: .director)
        default:
            throw NetworkError.emptyObject
        }
    }
    
    func setIncomeStatus(userID: String, model: RMIncomeConfirmation) async throws -> BaseResponse {
        switch userID {
        case "userID":
            return BaseResponse(description: nil, errors: nil, message: nil, statusCode: 200)
        default:
            throw NetworkError.unauthorized
        }
    }
}
