//
//  Token.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 15/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct Token: Decodable {
    public let accessToken: String
    public let expiresIn: Int
    public let tokenType: String
    public let date: Date = .init()
    
    public var isValid: Bool {
        date.addingTimeInterval(TimeInterval(expiresIn - 2)) > Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
    
}
