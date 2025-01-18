//
//  GoalServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 17/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQFoundation
@testable import AffordIQNetworkKit

class GoalServiceMock: GoalSource {
    func setSpendingGoal(userID: String, model: [RMSpendingTarget]) async throws -> SetGoalResponse {
        guard userID != "error" else { throw NetworkError.badID }
        
        return SetGoalResponse(description: "", errors: [], message: "", statusCode: 200)
    }
    
    func setPropertyGoal(userID: String, model: RMPropertyGoal) async throws -> BaseResponse {
        return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
    }
    
    func getAllGoals(userID: String) async throws -> AllGoalsResponse {
        guard userID != "error" else { throw NetworkError.badID }
        guard userID != "decodeFail" else { throw NetworkError.emptyBody }
        
        if userID == "depositGoalNil" {
            return AllGoalsResponse(
                description: "All goals",
                errors: [],
                message: "",
                statusCode: 200,
                spendingGoal: nil,
                savingsGoal: nil,
                propertyGoal: nil,
                depositGoal: nil,
                monthesUntilPurchase: nil
            )
        }
        
        return AllGoalsResponse(
            description: "All goals",
            errors: [],
            message: "",
            statusCode: 200,
            spendingGoal: nil,
            savingsGoal: SavingsGoal(monthlySavingsAmount: MonetaryAmount(amount: 100)),
            propertyGoal: nil,
            depositGoal: DepositGoal(
                id: 200,
                loanToValue: 0.1,
                parentGoalId: 200,
                state: ""),
            monthesUntilPurchase: nil
        )
    }
    
    func savingsGoal(userID: String, model: RMSavingGoalSet) async throws -> BaseResponse {
        guard userID != "error" else { throw NetworkError.badID }
        
        return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
    }
    
    func setSpendingGoal(userID: String, model: [RMSpendingTarget]) async throws -> BaseResponse {
        if userID == "work" {
            return BaseResponse(description: "", errors: [], message: " ", statusCode: 200)
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func setDepositGoal(userID: String, model: RMDepositGoal) async throws -> BaseResponse {
        if userID == "error" { throw NetworkError.badID }
        
        return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
    }
}
