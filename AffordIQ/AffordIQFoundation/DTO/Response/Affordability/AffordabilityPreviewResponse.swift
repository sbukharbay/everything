//
//  AffordabilityPreviewResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AffordabilityPreviewResponse: Response {
    public let affordabilityPreview: [AffordabilityPreviewModel]
    public let currentDeposit: MonetaryAmount
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case affordabilityPreview = "affordability_preview"
        case currentDeposit = "current_deposit"
        case description
        case errors
        case message
        case statusCode = "status_code"
    }
}
