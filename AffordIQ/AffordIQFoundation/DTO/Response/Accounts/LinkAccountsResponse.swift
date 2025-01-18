//
//  LinkAccountsResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct LinkAccountsResponse: Response {
    enum CodingKeys: String, CodingKey {
        case errors
        case message
        case statusCode = "status_code"
        case description
    }
    
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int
}
