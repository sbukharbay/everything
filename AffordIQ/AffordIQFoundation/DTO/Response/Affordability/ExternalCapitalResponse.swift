//
//  ExternalCapitalResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct ExternalCapitalResponse: Response, Equatable {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int
    public let externalCapitalAmount: MonetaryAmount
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case externalCapitalAmount = "external_capital_amount"
    }
}
