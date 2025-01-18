//
//  AccountNumber.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AccountNumber: Codable, Equatable {
    public let iban: String?
    public let number: String?
    public let sortCode: String?
    public let swiftBic: String?
    
    enum CodingKeys: String, CodingKey {
        case iban
        case number
        case sortCode = "sort_code"
        case swiftBic = "swift_bic"
    }
}
