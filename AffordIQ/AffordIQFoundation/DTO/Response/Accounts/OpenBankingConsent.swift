//
//  OpenBankingConsent.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct OpenBankingConsent: Codable, Equatable, Hashable {
    static let consentExpiryWarningDays = 7
    public let providerId: String
    public let consentStatus: ConsentStatus
    public let consentStatusUpdate: Date
    public let consentCreated: Date
    public let consentExpires: Date
    public let consentScopes: [ConsentScope]
    
    enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case consentStatus = "consent_status"
        case consentStatusUpdate = "consent_status_updated_at_date_time"
        case consentCreated = "consent_created_at_date_time"
        case consentExpires = "consent_expires_at_date_time"
        case consentScopes = "consent_scopes"
    }
}

public extension OpenBankingConsent {
    enum ConsentStatus: String, Codable {
        case authorized = "AUTHORISED"
        case awaitingAuthorization = "AWAITING_AUTHORISATION"
        case expired = "EXPIRED"
        case failedRetrieval = "FAILED_RETRIEVAL"
        case rejected = "REJECTED"
        case revoked = "REVOKED"
    }
    
    enum ConsentScope: String, Codable {
        case none = "NONE"
        case accounts = "ACCOUNTS"
        case balances = "BALANCES"
        case info = "INFO"
        case offlineAccess = "OFFLINE_ACCESS"
        case transactions = "TRANSACTIONS"
        case cards = "CARDS"
        case directDebits = "DIRECT_DEBITS"
        case standingOrders = "STANDING_ORDERS"
    }
}

public extension OpenBankingConsent {
    var isExpired: Bool {
        return consentExpires < systemDate
    }
    
    var isExpiring: Bool {
        if let consentExpiryCheck = Calendar.autoupdatingCurrent.date(byAdding: .day, value: OpenBankingConsent.consentExpiryWarningDays, to: systemDate) {
            return consentExpires < consentExpiryCheck
        }
        
        return false
    }
}

public struct OpenBankingReconsent: Response {
    public var description: String?
    public var errors: [String]?
    public var message: String?
    public var statusCode: Int
    public let trueLayerResponse: [TrueLayerModel]?
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case trueLayerResponse = "true_layer_response"
    }
}

public struct TrueLayerModel: Decodable, Equatable, Hashable {
    public let providerID: String
    public let response: TrueLayerResponse
    
    enum CodingKeys: String, CodingKey {
        case providerID = "provider_id"
        case response = "true_layer_response"
    }
}

public struct TrueLayerResponse: Decodable, Equatable, Hashable {
    public let accessToken: String?
    public let actionNeeded: ActionNeeded
    public let refreshToken: String?
    public let userInputLink: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case actionNeeded = "action_needed"
        case refreshToken = "refresh_token"
        case userInputLink = "user_input_link"
    }
}

public enum ActionNeeded: String, Codable {
    case authentication = "authentication_needed"
    case none = "no_action_needed"
}
