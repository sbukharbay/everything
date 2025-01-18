//
//  SetGoalResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 07/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct SetGoalResponse: Codable {
    let description: String?
    let errors: [String?]
    let message: String?
    let statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case description = "description"
        case errors, message
        case statusCode = "status_code"
    }
    
    public init(description: String?, errors: [String?], message: String?, statusCode: Int?) {
        self.description = description
        self.errors = errors
        self.message = message
        self.statusCode = statusCode
    }
}
