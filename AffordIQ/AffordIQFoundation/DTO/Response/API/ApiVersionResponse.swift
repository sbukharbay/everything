//
//  ApiVersionResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct ApiVersionResponse: Codable {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let build: ApiBuildDetails
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case build
    }
}
