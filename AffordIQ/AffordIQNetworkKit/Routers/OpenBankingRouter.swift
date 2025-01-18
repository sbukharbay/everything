//
//  OpenBankingRouter.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 04.05.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum OpenBankingRouter: RequestConvertible {
    case getProviders
    case authoriseCode(request: RMAuthoriseBank)
    case authorise(userID: String, providerID: String)
    case reconsent(userID: String, providers: ReconsentRequestModel)
    case checkAuthStatus(userID: String)
    
    public var path: String {
        switch self {
        case .getProviders:
            return "/api/openbanking/providers"
        case .authoriseCode:
            return "/api/openbanking/authorise/code"
        case .authorise(let userID, _):
            return "/api/openbanking/authorise/\(userID)"
        case .reconsent(let userID, _):
            return "/api/openbanking/reconfirm/consent/\(userID)"
        case .checkAuthStatus(let userID):
            return "/api/openbanking/authorise/status/\(userID)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getProviders, 
             .authoriseCode,
             .authorise,
             .checkAuthStatus:
            return .get
        case .reconsent:
            return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case let .authoriseCode(request):
            return ["code": request.code,
                    "scope": request.scope,
                    "state": request.state,
                    "providerId": request.providerID].toDictionary
        case let .authorise(_, providerID):
            return ["providerId": providerID].toDictionary
        default:
            return nil
        }
    }
    
    public var body: Body? {
        switch self {
        case .reconsent(_, let model):
            return model.asJson
        default: return nil
        }
    }
}
