//
//  BaseResponse.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct BaseResponse: Codable {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case description = "description"
        case errors, message
        case statusCode = "status_code"
    }
    
    public init(description: String?, errors: [String]?, message: String?, statusCode: Int?) {
        self.description = description
        self.errors = errors
        self.message = message
        self.statusCode = statusCode
    }
}
