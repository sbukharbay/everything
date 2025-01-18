//
//  UsernameExistsResponse.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct UsernameExistsResponse: Response {
    public let description: String?
    public let errors: [String]?
    public let exists: Bool
    public let message: String?
    public let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case exists
        case message
        case statusCode = "status_code"
    }
}
