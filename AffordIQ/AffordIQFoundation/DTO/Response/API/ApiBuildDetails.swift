//
//  ApiBuildDetails.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct ApiBuildDetails: Codable {
    public let artifact: String
    public let name: String
    public let time: String
    public let version: String
    public let group: String
    
    enum CodingKeys: String, CodingKey {
        case artifact
        case name
        case time
        case version
        case group
    }
}
