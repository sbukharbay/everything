//
//  InstitutionAccountsResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct InstitutionAccountsResponse: Response, Codable {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int
    public let institutionAccounts: [InstitutionAccount]?
    public let openBankingConsents: [OpenBankingConsent]?
    
    enum CodingKeys: String, CodingKey {
        case errors
        case message
        case statusCode = "status_code"
        case description
        case institutionAccounts = "institution_accounts"
        case openBankingConsents = "open_banking_consent_list"
    }
}
