//
//  SpendingSummaryViewModelTests.swift
//  AffordIQ
//
//  Created by Asilbek Djamaldinov on 13/04/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class SpendingSummaryViewModelTests: XCTestCase {
    var sut: SpendingSummaryViewModel!
    var userSessionMock: UserSessionMock!
    var spendingSourceMock: SpendingServiceMock!
    
    override func setUp() {
        super.setUp()
        userSessionMock = UserSessionMock.getMock()
        spendingSourceMock = SpendingServiceMock()
        sut = SpendingSummaryViewModel(spendingSource: spendingSourceMock, userSession: userSessionMock, isSettings: false)
    }
    
    override func tearDown() {
        sut = nil
        userSessionMock = nil
        spendingSourceMock = nil
        super.tearDown()
    }
    
    // MARK: - Testing
    func test_init_getStartedType_isInitial() {
        // given
        let type: GetStartedViewType = .initial
        
        // when
        sut = SpendingSummaryViewModel(getStartedType: type, isSettings: false)
        
        // then
        XCTAssertEqual(sut.getStartedType, type)
    }
    
    func test_getAverageMonthlySpending_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.getAverageMonthlySpending()
        
        // then
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_getAverageMonthlySpending_didSpendingCategoriesReceived() async {
        // given
        userSessionMock.userID = "success"
        let response = AverageSpendingSummaryResponse(monthlyAverage: MonetaryAmount(amount: 5),
                                                      averageCategorisedTransactions: [], statusCode: 200)
        
        // when
        await sut.getAverageMonthlySpending()
        
        // then
        XCTAssertEqual(sut.spendingCategories?.monthlyAverage.amount, response.monthlyAverage.amount)
    }
    
    func test_getCategorisedTransactions_didReturnTransactions() {
        // given
        let data = AverageSpendingSummaryResponse(
            monthlyAverage: MonetaryAmount(amount: 10),
            averageCategorisedTransactions: [
                // First
                AverageCategorisedTransactionsModel(
                    categorisedTransactionsType: TransactionTypes.nonDiscretionary.value,
                    categorisedTransactionsSummaries: [
                        CategorisedTransactionsSummariesModel(
                            categoryId: 1, categoryName: "Category name",
                            averageValue: MonetaryAmount(amount: 10))
                    ]
                ),
                // Second
                AverageCategorisedTransactionsModel(
                    categorisedTransactionsType: TransactionTypes.discretionary.value,
                    categorisedTransactionsSummaries: [
                        CategorisedTransactionsSummariesModel(
                            categoryId: 2, categoryName: "Category name",
                            averageValue: MonetaryAmount(amount: 10))
                    ]
                ),
                // Third
                AverageCategorisedTransactionsModel(
                    categorisedTransactionsType: TransactionTypes.banking.value,
                    categorisedTransactionsSummaries: [
                        CategorisedTransactionsSummariesModel(
                            categoryId: 3, categoryName: "Category name",
                            averageValue: MonetaryAmount(amount: 10))
                    ]
                )
            ],
            statusCode: 200)
        
        // when
        let result = sut.getCategorisedTransactions(data: data)
        
        // then
        XCTAssertEqual(result[0].categorisedTransactionsSummaries[0].categoryId,
                       data.averageCategorisedTransactions[0].categorisedTransactionsSummaries[0].categoryId)
        XCTAssertEqual(result[1].categorisedTransactionsSummaries[0].categoryId,
                       data.averageCategorisedTransactions[1].categorisedTransactionsSummaries[0].categoryId)
        XCTAssertEqual(result[2].categorisedTransactionsSummaries[0].categoryId,
                       data.averageCategorisedTransactions[2].categorisedTransactionsSummaries[0].categoryId)
    }
    
    func test_fetchSubCategory_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.fetchSubCategory(for: 0)
        
        // then
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_fetchSubCategory_isSubCategoryDataEqual() async {
        // given
        userSessionMock.userID = "success"
        let categoryName = "Hello"
        
        // when
        await sut.fetchSubCategory(for: 0)
        
        // then
        XCTAssertEqual(sut.subCategoryData?.parentCategorySpendingSummary.categoryName, categoryName)
    }
}
