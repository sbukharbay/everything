//
//  TransactionsRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 08/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum TransactionsRouter: RequestConvertible {
    case getTransactionsStatus(userID: String)
    case confirmSpendingCategories(userID: String)
    case getTransactionsSpending(userID: String)
    case transactionsRecategorise(userID: String, model: [RMTransactionsRecategorise])
    
    public var path: String {
        switch self {
        case .getTransactionsStatus(let userID):
            return "/api/transactions/status/\(userID)"
        case .confirmSpendingCategories(let userID):
            return "/api/transactions/confirm-spending-categories/\(userID)"
        case .getTransactionsSpending(let userID):
            return "/api/transactions/spending/landing/\(userID)"
        case .transactionsRecategorise(let userID, _):
            return "/api/transactions/recategorise/\(userID)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getTransactionsStatus,
             .getTransactionsSpending:
            return .get
        case .confirmSpendingCategories,
             .transactionsRecategorise:
            return .post
        }
    }
    
    public var body: Body? {
        switch self {
        case .transactionsRecategorise(_, let model):
            return model.asJson
        default: return nil
        }
    }
}
