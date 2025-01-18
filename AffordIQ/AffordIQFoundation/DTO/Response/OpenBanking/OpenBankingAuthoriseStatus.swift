//
//  OpenBankingAuthoriseStatus.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 31/10/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct OpenBankingAuthoriseStatus: Codable {
    public var description: String?
    public var errors: [String]?
    public var institutionID: String?
    public var isAuthorisationComplete: Bool = false
    public var message: String?
    public var statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case description, errors
        case institutionID = "institution_id"
        case isAuthorisationComplete = "is_authorisation_complete"
        case message
        case statusCode = "status_code"
    }
    
    public init(description: String, errors: [String], institutionID: String, isAuthorisationComplete: Bool, message: String, statusCode: Int) {
        self.description = description
        self.errors = errors
        self.institutionID = institutionID
        self.isAuthorisationComplete = isAuthorisationComplete
        self.message = message
        self.statusCode = statusCode
    }
}
