//
//  SpendingServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 10/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class SpendingServiceMock: SpendingSource {
    var willThrowError = false
    
    func getSpendingSurplus(userID: String) async throws -> SpendingSurplusResponse {
        if userID == "surplus" {
            let monetaryAmount = MonetaryAmount(amount: -10)
            return SpendingSurplusResponse(surplus: monetaryAmount, statusCode: 200)
        }
        let monetaryAmount = MonetaryAmount(amount: 100)
        return SpendingSurplusResponse(surplus: monetaryAmount, statusCode: 200)
    }
    
    func getSpendingCategories() async throws -> SpendingCategoryResponse {
        guard !willThrowError else { throw NetworkError.badID }
        let child = [ChildCategoriesModel(id: 0, name: "Child Category 1"),
                     ChildCategoriesModel(id: 1, name: "Child Category 2"),
                     ChildCategoriesModel(id: 2, name: "Child Category 3")]
        let model = SpendingCategoriesModel(categoryId: 1, categoryName: "New category", childCategory: child)
        return SpendingCategoryResponse(spendingCategories: [model], statusCode: 200)
    }
    
    func getSpendingSummary(userID: String) async throws -> AverageSpendingSummaryResponse {
        AverageSpendingSummaryResponse(monthlyAverage: MonetaryAmount(amount: 5), averageCategorisedTransactions: [], statusCode: 200)
    }
    
    func getSpendingSubcategories(userID: String, categoryID: Int) async throws -> AverageSubCategorySpendingSummaryResponse {
        AverageSubCategorySpendingSummaryResponse(
            parentCategorySpendingSummary: CategorisedTransactionsSummariesModel(categoryId: 1, categoryName: "Hello", averageValue: MonetaryAmount(amount: 5)),
            subCategorisedSpendingSummaries: [],
            statusCode: 200
        )
    }
    
    func getMonthlySpending(userID: String) async throws -> MonthlyBudgetDetailsResponse {
        MonthlyBudgetDetailsResponse(statusCode: 200,
                                     discretionary: DiscretionaryMonthlyBudgetResponse(targetSpend: MonetaryAmount(amount: 500), leftToSpend: MonetaryAmount(amount: 300), pattern: .meet),
                                     nonDiscretionary: NonDiscretionaryMonthlyBudgetResponse(averageSpend: MonetaryAmount(amount: 400), currentSpend: MonetaryAmount(amount: 200)),
                                     totalSpend: MonetaryAmount(amount: 200))
    }
    
    func getMonthlyBreakdown(userID: String) async throws -> MonthlyBreakdownResponse {
        MonthlyBreakdownResponse(
            statusCode: 200,
            discretionary: [SpendingBreakdownCategory(order: 0, id: 1, name: "Clothes", actualSpend: MonetaryAmount(amount: 150), monthlyAverage: MonetaryAmount(amount: 500), parentCategoryName: "Shopping", spendGoalPercentage: 50)],
            nonDiscretionary: [SpendingBreakdownCategory(order: 0, id: 1, name: "Food", actualSpend: MonetaryAmount(amount: 100), monthlyAverage: MonetaryAmount(amount: 100), parentCategoryName: "Meal", spendGoalPercentage: 60)]
        )
    }
    
    func getTopFourSpendingCategories(userID: String) async throws -> TopSpendingCategoriesResponse {
        if userID == "work" {
            return TopSpendingCategoriesResponse(statusCode: 200, topMonthlyAverageSpending: [
                TopAverageSpendingModel(categoryName: "Category 1", categoryId: 1, averageSpend: MonetaryAmount(amount: nil), spendingGoal: MonetaryAmount(amount: 200), order: 1),
                TopAverageSpendingModel(categoryName: "Category 2", categoryId: 2, averageSpend: MonetaryAmount(amount: 200), order: 2),
                TopAverageSpendingModel(categoryName: "Category 3", categoryId: 3, averageSpend: MonetaryAmount(amount: 300), order: 3),
                TopAverageSpendingModel(categoryName: "Category 4", categoryId: 4, averageSpend: MonetaryAmount(amount: 400), order: 4)
            ])
        } else {
            throw NetworkError.unauthorized
        }
    }
}
