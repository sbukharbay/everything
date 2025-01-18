//
//  MorgageAffordabilityRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 06/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum MorgageAffordabilityRouter: RequestConvertible {
    case goalTrackingAndMorgageLimit(userID: String)
    
    public var path: String {
        switch self {
        case .goalTrackingAndMorgageLimit(let userID): return "/api/affordability/\(userID)/goal-tracking-and-mortgage-limits"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .goalTrackingAndMorgageLimit:
            return .get
        }
    }
    
    public var isAuthorized: Bool {
        switch self {
        case .goalTrackingAndMorgageLimit:
            return true
        }
    }
}
