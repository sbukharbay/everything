//
//  OnboardingRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 21/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum OnboardingRouter: RequestConvertible {
    case onboardingComplete(userID: String)
    
    public var path: String {
        switch self {
        case .onboardingComplete(let userID): return "/api/users/completed-onboarding/\(userID)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .onboardingComplete:
            return .post
        }
    }
}
