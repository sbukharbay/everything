//
//  RMFetchToken.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 16/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMFetchToken: Encodable {
    public let clientId: String
    public let clientSecret: String
    public let audience: String
    public let grantType: String
    
    public init(clientId: String, clientSecret: String, audience: String, grantType: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.audience = audience
        self.grantType = grantType
    }
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case audience
        case grantType = "grant_type"
    }
}
