//
//  SpendingSource.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 19/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol SpendingSource {
    func getSpendingSurplus(userID: String) async throws -> SpendingSurplusResponse
    
    func getSpendingCategories() async throws -> SpendingCategoryResponse
    
    func getSpendingSummary(userID: String) async throws -> AverageSpendingSummaryResponse
    
    func getSpendingSubcategories(userID: String, categoryID: Int) async throws -> AverageSubCategorySpendingSummaryResponse
    
    func getTopFourSpendingCategories(userID: String) async throws -> TopSpendingCategoriesResponse
    
    func getMonthlySpending(userID: String) async throws -> MonthlyBudgetDetailsResponse
    
    func getMonthlyBreakdown(userID: String) async throws -> MonthlyBreakdownResponse
}

public final class SpendingService: AdaptableNetwork<SpendingRouter>, SpendingSource {
    public func getSpendingSurplus(userID: String) async throws -> SpendingSurplusResponse {
        try await request(SpendingSurplusResponse.self, from: .getSpendingSurplus(userID: userID))
    }
    
    public func getSpendingCategories() async throws -> SpendingCategoryResponse {
        try await request(SpendingCategoryResponse.self, from: .getSpendingCategories)
    }
    
    public func getSpendingSummary(userID: String) async throws -> AverageSpendingSummaryResponse {
        try await request(AverageSpendingSummaryResponse.self, from: .getSpendingSummary(userID: userID))
    }
    
    public func getSpendingSubcategories(userID: String, categoryID: Int) async throws -> AverageSubCategorySpendingSummaryResponse {
        try await request(
            AverageSubCategorySpendingSummaryResponse.self,
            from: .getSpendingSubcategories(userID: userID, categoryID: categoryID)
        )
    }
    
    public func getTopFourSpendingCategories(userID: String) async throws -> TopSpendingCategoriesResponse {
        try await request(TopSpendingCategoriesResponse.self, from: .getTopFourSpendingCategories(userID: userID))
    }
    
    public func getMonthlySpending(userID: String) async throws -> MonthlyBudgetDetailsResponse {
        try await queryRequest(MonthlyBudgetDetailsResponse.self, from: .getMonthlySpending(userID: userID))
    }
    
    public func getMonthlyBreakdown(userID: String) async throws -> MonthlyBreakdownResponse {
        try await request(MonthlyBreakdownResponse.self, from: .getMonthlyBreakdown(userID: userID))
    }
}
