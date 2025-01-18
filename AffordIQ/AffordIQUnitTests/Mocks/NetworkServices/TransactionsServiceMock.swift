//
//  TransactionsServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 17/04/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class TransactionsServiceMock: TransactionsSource {
    var didRecatigorise = false
    
    func getTransactionsStatus(userID: String) async throws -> TransactionsStatus {
        throw NetworkError.badID
    }
    
    func confirmSpendingCategories(userID: String) async throws -> BaseResponse {
        throw NetworkError.badID
    }
    
    func getTransactionsSpending(userID: String) async throws -> RecurringTransactionCategoryResponse {
        RecurringTransactionCategoryResponse(
            recurringPayments: [
                RecurringTransactionsModel(
                    transactionDescription: "Description",
                    amount: MonetaryAmount(amount: 10),
                    paymentPattern: "PaymentPattern",
                    categoryId: 1,
                    categoryName: "categoryName",
                    transactionsIdentifiers: [])
            ],
            statusCode: 200)
    }
    
    func transactionsRecategorise(userID: String, model: [RMTransactionsRecategorise]) async throws -> BaseResponse {
        if userID == "success" {
            didRecatigorise = true
            return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
        } else {
            throw NetworkError.badID
        }
    }
}
