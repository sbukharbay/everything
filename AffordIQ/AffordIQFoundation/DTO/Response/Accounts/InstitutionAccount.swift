//
//  InstitutionAccount.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct InstitutionAccount: Codable, Comparable {
    public let institutionId: String
    public let accountId: String
    public let accountNumber: AccountNumber?
    public let accountType: AccountType?
    public let balance: AccountBalance?
    public let displayName: String?
    public let providerDisplayName: String
    public let lastUpdated: Date?
    public let providerLogoUri: String
    #if DEBUG
    public var usedForDeposit: Bool
    #else
    public let usedForDeposit: Bool
    #endif
    public var consent: OpenBankingConsent?
    
    enum CodingKeys: String, CodingKey {
        case institutionId = "institution_id"
        case accountId = "account_id"
        case accountNumber = "account_number"
        case accountType = "account_type"
        case balance
        case displayName = "display_name"
        case providerDisplayName = "provider_display_name"
        case lastUpdated = "last_updated_date_time"
        case providerLogoUri = "provider_logo_uri"
        case usedForDeposit = "used_for_deposit"
        case consent
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        let lhsAccountNumber = lhs.accountNumber?.number ?? ""
        let rhsAccountNumber = rhs.accountNumber?.number ?? ""
        let lhsSortCode = lhs.accountNumber?.sortCode ?? ""
        let rhsSortCode = rhs.accountNumber?.sortCode ?? ""
        
        return (lhs.providerDisplayName, lhs.displayName ?? "", lhsSortCode, lhsAccountNumber, lhs.accountId) < (rhs.providerDisplayName, rhs.displayName ?? "", rhsSortCode, rhsAccountNumber, rhs.accountId)
    }
}

extension InstitutionAccount: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(institutionId)
        hasher.combine(accountId)
        hasher.combine(consent?.consentExpires)
    }
}

public extension InstitutionAccount {
    enum AccountType: String, Codable, Comparable, Hashable, Equatable {
        case businessCurrent = "BUSINESS_CURRENT_ACCOUNT"
        case businessSavings = "BUSINESS_SAVINGS"
        case creditCard = "CREDIT_CARD_ACCOUNT"
        case current = "CURRENT_ACCOUNT"
        case savings = "SAVINGS_ACCOUNT"
        case undefined = "UNDEFINED_ACCOUNT"
        
        public static func < (lhs: InstitutionAccount.AccountType, rhs: InstitutionAccount.AccountType) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}
