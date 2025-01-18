//
//  RMLinkAccounts.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMLinkAccounts: Encodable {
    public let accountInstitutionID: String
    public let accountsToLink: [String]
    public let userID: String
    
    public init(accountInstitutionID: String, accountsToLink: [String], userID: String) {
        self.accountInstitutionID = accountInstitutionID
        self.accountsToLink = accountsToLink
        self.userID = userID
    }
    
    enum CodingKeys: String, CodingKey {
        case accountInstitutionID = "account_institution_id"
        case accountsToLink = "accounts_to_link"
        case userID = "user_id"
    }
}
