//
//  ExternalIdentityProviderResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct ExternalIdentityProviderResponse: Response {
    public let description: String?
    public let errors: [String]?
    public let userID: String?
    public let message: String?
    public let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case userID = "user_id"
        case message
        case statusCode = "status_code"
    }
}
