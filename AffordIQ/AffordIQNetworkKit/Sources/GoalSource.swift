//
//  GoalSource.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 19/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol GoalSource {
    func getAllGoals(userID: String) async throws -> AllGoalsResponse
    
    @discardableResult
    func savingsGoal(userID: String, model: RMSavingGoalSet) async throws -> BaseResponse
    
    @discardableResult
    func setSpendingGoal(userID: String, model: [RMSpendingTarget]) async throws -> SetGoalResponse
    
    @discardableResult
    func setDepositGoal(userID: String, model: RMDepositGoal) async throws -> BaseResponse
    
    @discardableResult
    func setPropertyGoal(userID: String, model: RMPropertyGoal) async throws -> BaseResponse
}

public final class GoalService: AdaptableNetwork<GoalRouter>, GoalSource {
    public func getAllGoals(userID: String) async throws -> AllGoalsResponse {
        try await request(AllGoalsResponse.self, from: .getAllGoals(userID: userID))
    }
    
    public func savingsGoal(userID: String, model: RMSavingGoalSet) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .savingsGoal(userID: userID, model: model))
    }
    
    public func setSpendingGoal(userID: String, model: [RMSpendingTarget]) async throws -> SetGoalResponse {
        try await request(SetGoalResponse.self, from: .setSpendingGoal(userID: userID, model: model))
    }
    
    public func setDepositGoal(userID: String, model: RMDepositGoal) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .setDepositGoal(userID: userID, model: model))
    }
    
    public func setPropertyGoal(userID: String, model: RMPropertyGoal) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .setPropertyGoal(userID: userID, model: model))
    }
}
