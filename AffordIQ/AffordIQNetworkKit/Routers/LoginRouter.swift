//
//  LoginRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 16/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum LoginRouter: RequestConvertible {
    case fetchToken(model: RMFetchToken)
    
    public var path: String {
        switch self {
        case .fetchToken:
            return "/oauth/token"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .fetchToken:
            return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .fetchToken(let model):
            return model.toLoginDictionary
        }
    }
    
    public var isAuthorized: Bool {
        switch self {
        case .fetchToken:
            return false
        }
    }
    
    public var environment: String {
        return Environment.shared.issuerURI.absoluteString
    }
}
