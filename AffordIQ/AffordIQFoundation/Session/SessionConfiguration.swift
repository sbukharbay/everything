//
//  SessionConfiguration.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

/// Handler for the result of a token retrieval operation.
/// - Parameters:
///   - token: an access token if the operation succeeded, nil otherwise.
///   - error: any error arising from the authentication operation.
public typealias SessionTokenCompletion = (_ token: String?, _ error: Error?) -> Void

/// Handler for the result of an authentication operation.
/// - Parameters:
///   - ok: `true` if the operation succeeded, `false` otherwise.
///   - error: any error arising from the authentication operation.
public typealias SessionAuthenticationCompletion = (_ ok: Bool, _ error: Error?) -> Void

/// An authentication configuration for a session.
public struct SessionConfiguration {
    /// The invariant client ID of the application.
    public let clientId: String
    /// The issuer of the authentication grant.
    public let issuer: String
    /// Requested OAUTH scopes for the application.
    public let scopes: [String]
    /// A URI that will be received as a redirect by the client on login.
    public let redirectUri: String
    /// A URI that will be received as a redirect by the client on logout.
    public let logoutRedirectUri: String
    /// A URI for the API that will be accessed by the client.
    public let audienceUri: String
    /// The invariant client secret of the web application.
    public let webClientSecret: String
    /// The invariant client ID of the web application.
    public let webClientId: String
    /// Type of scope to retrieve Auth0 token.
    public let webGrantType: String
    
    public init(clientId: String, issuer: String, scopes: [String], redirectUri: String, logoutRedirectUri: String, audienceUri: String, webClientSecret: String, webClientId: String, webGrantType: String) {
        self.clientId = clientId
        self.issuer = issuer
        self.scopes = scopes
        self.redirectUri = redirectUri
        self.logoutRedirectUri = logoutRedirectUri
        self.audienceUri = audienceUri
        self.webClientSecret = webClientSecret
        self.webClientId = webClientId
        self.webGrantType = webGrantType
    }
}
