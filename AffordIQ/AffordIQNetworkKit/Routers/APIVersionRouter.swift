//
//  APIVersionRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 03/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum APIVersionRouter: RequestConvertible {
    case getApiVersionNumber
    
    public var path: String {
        switch self {
        case .getApiVersionNumber:
            return "/actuator/info"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getApiVersionNumber:
            return .get
        }
    }
}
