//
//  AccountsRouter.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 04.05.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum AccountsRouter: RequestConvertible {
    case getInstitutionAccounts(userID: String, institutionID: String)
    case getAccounts(userID: String)
    case link(model: RMLinkAccounts)
    
    public var path: String {
        switch self {
        case let .getInstitutionAccounts(userID, institutionID):
            return "/api/accounts/openbanking/\(userID)/\(institutionID)"
        case let .getAccounts(userID):
            return "/api/accounts/\(userID)"
        case .link:
            return "/api/accounts/link"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getInstitutionAccounts,
             .getAccounts:
            return .get
        case .link:
            return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .link(let model):
            return model.toDictionary
        default:
            return nil
        }
    }
}
