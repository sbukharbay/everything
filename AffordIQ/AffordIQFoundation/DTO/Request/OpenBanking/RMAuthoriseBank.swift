//
//  RMAuthoriseBank.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMAuthoriseBank: Encodable {
    public let code: String
    public let scope: String
    public let state: String
    public let providerID: String
    
    public init(code: String, scope: String, state: String, providerID: String) {
        self.code = code
        self.scope = scope
        self.state = state
        self.providerID = providerID
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case scope
        case state
        case providerID
    }
}

public struct ReconsentRequestModel: Codable {
    public var providers: [ReconsentProvider]
    
    public init(providers: [ReconsentProvider]) {
        self.providers = providers
    }
    
    enum CodingKeys: String, CodingKey {
        case providers
    }
}

public struct ReconsentProvider: Codable {
    public var provider: String
    public var renew: Bool
    
    public init(provider: String, renew: Bool) {
        self.provider = provider
        self.renew = renew
    }
    
    enum CodingKeys: String, CodingKey {
        case provider = "institution_id"
        case renew = "renew_consent"
    }
}
