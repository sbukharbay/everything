//
//  AuthError.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 16/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum AuthError: Error {
    case missingToken
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingToken:
            return NSLocalizedString("Your session has expired. Please sign in with your email address and password.", comment: "My error")
        }
    }
}
