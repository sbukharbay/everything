//
//  Auth0UserResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct Auth0UserResponse: Response {
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case emailVerified = "email_verified"
    }
    
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int
    public let emailVerified: Bool
}
