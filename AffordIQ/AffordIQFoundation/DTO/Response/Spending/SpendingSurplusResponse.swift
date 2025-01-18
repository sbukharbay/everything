//
//  SpendingSurplusResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct SpendingSurplusResponse: Response {
    public var surplus: MonetaryAmount
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    public var userId: String?
    
    enum CodingKeys: String, CodingKey {
        case surplus
        case description
        case errors
        case message
        case statusCode = "status_code"
        case userId = "user_id"
    }
}
