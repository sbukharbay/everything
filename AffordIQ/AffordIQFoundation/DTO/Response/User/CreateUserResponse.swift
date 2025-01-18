//
//  CreateUserResponse.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct CreateUserResponse: Response {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int
    public let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case userId = "user_id"
    }
}
