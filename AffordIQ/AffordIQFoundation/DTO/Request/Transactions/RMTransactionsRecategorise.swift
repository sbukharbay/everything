//
//  RMTransactionsRecategorise.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMTransactionsRecategorise: Encodable {
    public var transactions: [TransactionRecategoriseDetail]
    public let applyToSimilar: Bool
    public let categoryId: Int
    
    public init(transactions: [TransactionRecategoriseDetail], categoryId: Int) {
        self.transactions = transactions
        self.categoryId = categoryId
        applyToSimilar = true
    }
    
    enum CodingKeys: String, CodingKey {
        case transactions
        case applyToSimilar = "apply_to_similar"
        case categoryId = "category_id"
    }
}

public struct TransactionRecategoriseDetail: Codable, Equatable, Hashable {
    public let accountId: String
    public let amount: StringMonetaryAmount
    public let description: String
    public let transactionDateTime: String
    
    public init(accountId: String, amount: StringMonetaryAmount, description: String, transactionDateTime: String) {
        self.accountId = accountId
        self.amount = amount
        self.description = description
        self.transactionDateTime = transactionDateTime
    }
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case amount
        case description
        case transactionDateTime = "transaction_date_time"
    }
}
