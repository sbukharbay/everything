//
//  RMTerms.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 28/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMTerms: Codable {
    public let userID: String
    public let acceptanceDate: String
    public let version: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case acceptanceDate = "acceptance_date_time"
        case version = "tsandcs_version"
    }
    
    public init(userID: String, date: String, version: String) {
        self.userID = userID
        acceptanceDate = date
        self.version = version
    }
}
