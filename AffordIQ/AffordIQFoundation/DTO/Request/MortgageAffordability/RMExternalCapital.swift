//
//  ExternalCapitalRequest.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMExternalCapital: Codable {
    public let description: String
    public let value: MonetaryAmount
    
    public init(description: String, value: MonetaryAmount) {
        self.description = description
        self.value = value
    }
}
