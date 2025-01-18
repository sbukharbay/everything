//
//  TransactionsSource.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 08/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol TransactionsSource {
    func getTransactionsStatus(userID: String) async throws -> TransactionsStatus
    
    @discardableResult
    func confirmSpendingCategories(userID: String) async throws -> BaseResponse
    
    func getTransactionsSpending(userID: String) async throws -> RecurringTransactionCategoryResponse
    
    @discardableResult
    func transactionsRecategorise(userID: String, model: [RMTransactionsRecategorise]) async throws -> BaseResponse
}

public final class TransactionsService: AdaptableNetwork<TransactionsRouter>, TransactionsSource {
    public func getTransactionsStatus(userID: String) async throws -> TransactionsStatus {
        try await request(TransactionsStatus.self, from: .getTransactionsStatus(userID: userID))
    }
    
    public func confirmSpendingCategories(userID: String) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .confirmSpendingCategories(userID: userID))
    }
    
    public func getTransactionsSpending(userID: String) async throws -> RecurringTransactionCategoryResponse {
        try await request(RecurringTransactionCategoryResponse.self, from: .getTransactionsSpending(userID: userID))
    }
    
    public func transactionsRecategorise(userID: String, model: [RMTransactionsRecategorise]) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .transactionsRecategorise(userID: userID, model: model))
    }
}
