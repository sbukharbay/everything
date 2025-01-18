//
//  FetchTokenResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct FetchTokenResponse: Decodable {
    public let accessToken: String
    public let expiresIn: Int
    public let tokenType: String
    public let date: Date = .init()
    
    public var isExpired: Bool {
        date.addingTimeInterval(TimeInterval(expiresIn - 2)) < Date()
    }
    
    public init(accessToken: String, expiresIn: Int, tokenType: String) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}
