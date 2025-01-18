//
//  SpendingRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 19/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum SpendingRouter: RequestConvertible {
    case getSpendingSurplus(userID: String)
    case getSpendingCategories
    case getSpendingSummary(userID: String)
    case getSpendingSubcategories(userID: String, categoryID: Int)
    case getTopFourSpendingCategories(userID: String)
    case getMonthlySpending(userID: String)
    case getMonthlyBreakdown(userID: String)
    
    public var path: String {
        switch self {
        case .getSpendingSurplus(let userID):
            return "/api/spending/surplus/\(userID)"
        case .getSpendingCategories:
            return "/api/spending/categories"
        case .getSpendingSummary(let userID):
            return "/api/spending/categorised/summary/\(userID)"
        case let .getSpendingSubcategories(userID, categoryID):
            return "/api/spending/categorised/\(userID)/\(categoryID)"
        case .getTopFourSpendingCategories(let userID):
            return "/api/spending/top-categories/\(userID)"
        case .getMonthlySpending(let userID):
            return "/api/spending/monthly/\(userID)"
        case .getMonthlyBreakdown(let userID):
            return "/api/spending/monthly/breakdown/\(userID)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getSpendingSurplus,
             .getSpendingCategories,
             .getSpendingSummary,
             .getSpendingSubcategories,
             .getTopFourSpendingCategories,
             .getMonthlySpending,
             .getMonthlyBreakdown:
            return .get
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .getMonthlySpending:
            return ["month": "0", "type": "ALL"].toDictionary
        default: return nil
        }
    }
}
