//
//  AffordabilitySource.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 17/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol AffordabilitySource {
    /// * GET [Callback to get mortgage details]
    func getMortgageDetails(
        userID: String,
        depositAbsoluteValue: String,
        propertyValue: String
    ) async throws -> MortgageDetailsResponse
    
    /// GET [Goal Tracking and Mortgage Limits Data for Customer Dashboard.]
    func getGoalTrackingAndMortgageLimits(userID: String) async throws -> PropertyGoalAndMortgageLimitsResponse
    
    /// * GET [Callback to get affordability calculation]
    ///
    /// UserID - non-optional
    /// Month - optional
    func getAffordabilityCalculations(userID: String, model: RMAffordabilityCalculations?) async throws -> AffordabilityCalculationsResponse
    
    /// * GET [Callback to validate if the affordability calculation has been completed]
    func getAffordabilityStatus(userID: String) async throws -> TransactionsStatus
    
    /// * GET[callback to get current deposit/ target deposit/months until affordable]
    func getAffordabilityPreview(userID: String) async throws -> AffordabilityPreviewResponse
    
    /// * GET[Retrieves Employment Status / Annual Gross Salary / Annual Bonus / Monthly Salary for a given user]
    func getIncomeStatus(userID: String) async throws -> IncomeBreakdownResponse
    
    /// * POST[Creates Employment Status / Annual Gross Salary / Annual Bonus / Monthly Salary for a given user]
    @discardableResult
    func setIncomeStatus(userID: String, model: RMIncomeConfirmation) async throws -> BaseResponse
}

public final class AffordabilityService: AdaptableNetwork<AffordabilityRouter>, AffordabilitySource {
     public func getMortgageDetails(
        userID: String,
        depositAbsoluteValue: String,
        propertyValue: String
     ) async throws -> MortgageDetailsResponse {
         try await request(
            MortgageDetailsResponse.self,
            from: .getMortgageDetails(
                userID: userID,
                depositAbsoluteValue: depositAbsoluteValue,
                propertyValue: propertyValue
            )
         )
    }
    
    public func getGoalTrackingAndMortgageLimits(userID: String) async throws -> PropertyGoalAndMortgageLimitsResponse {
        try await request(PropertyGoalAndMortgageLimitsResponse.self, from: .getGoalTrackingAndMortgageLimits(userID: userID))
    }
    
    public func getAffordabilityCalculations(userID: String, model: RMAffordabilityCalculations?) async throws -> AffordabilityCalculationsResponse {
        try await request(AffordabilityCalculationsResponse.self, from: .getAffordabilityCalculations(userID: userID, model: model))
    }
    
    public func getAffordabilityStatus(userID: String) async throws -> TransactionsStatus {
        try await request(TransactionsStatus.self, from: .getAffordabilityStatus(userID: userID))
    }
    
    public func getAffordabilityPreview(userID: String) async throws -> AffordabilityPreviewResponse {
        try await request(AffordabilityPreviewResponse.self, from: .getAffordabilityPreview(userID: userID))
    }
    
    public func getIncomeStatus(userID: String) async throws -> IncomeBreakdownResponse {
        try await request(IncomeBreakdownResponse.self, from: .getIncomeStatus(userID: userID))
    }
    
    public func setIncomeStatus(userID: String, model: RMIncomeConfirmation) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .setIncomeStatus(userID: userID, model: model))
    }
}
