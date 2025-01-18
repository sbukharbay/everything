//
//  RecurringTransactionCategoryResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RecurringTransactionCategoryResponse: Response {
    public var recurringPayments: [RecurringTransactionsModel]
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case recurringPayments = "recurring_payments"
        case description
        case errors
        case message
        case statusCode = "status_code"
    }
}

public struct RecurringTransactionsModel: Codable {
    public let transactionDescription: String
    public let amount: MonetaryAmount
    public let paymentPattern: String
    public let categoryId: Int
    public let categoryName: String?
    public let transactionsIdentifiers: [TransactionsIdentifiers]
    
    enum CodingKeys: String, CodingKey {
        case transactionDescription = "transaction_description"
        case amount = "monetary_amount"
        case paymentPattern = "payment_pattern"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case transactionsIdentifiers = "transaction_identifiers"
    }
}

public struct TransactionsIdentifiers: Codable {
    public let accountId: String
    public let transactionDateTime: String
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case transactionDateTime = "transaction_date_time"
    }
}
