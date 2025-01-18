//
//  DepositRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 07/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum DepositRouter: RequestConvertible {
    case confirmSavings(userID: String)
    case deleteExternalCapital(userID: String)
    case getExternalCapital(userID: String)
    case createExternalCapital(userID: String, model: RMExternalCapital)
    case updateExternalCapital(userID: String, model: RMExternalCapital)
    case getBalance(userID: String)
    case updateAccounts(model: RMAccountsUsedForDeposit)
    
    public var path: String {
        switch self {
        case .confirmSavings(let userID):
            return "/api/deposit/confirm/\(userID)"
        case .deleteExternalCapital(let userID),
             .getExternalCapital(let userID),
             .createExternalCapital(let userID, _),
             .updateExternalCapital(let userID, _):
            return "/api/deposit/externalcapital/\(userID)"
        case .getBalance(let userID):
            return "/api/deposit/balance/\(userID)"
        case .updateAccounts:
            return "/api/deposit/accounts"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getExternalCapital,
             .getBalance:
            return .get
        case .confirmSavings,
             .createExternalCapital,
             .updateAccounts:
            return .post
        case .deleteExternalCapital:
            return .delete
        case .updateExternalCapital:
            return .put
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .updateExternalCapital(_, let model),
             .createExternalCapital(_, let model):
            return model.toDictionary
        case .updateAccounts(let model):
            return model.toDictionary
        default: return nil
        }
    }
}
