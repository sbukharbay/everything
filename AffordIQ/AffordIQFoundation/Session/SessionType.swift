//
//  SessionType.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import UIKit

/// The current user's session.
public protocol SessionType: AnyObject {
    /// `true` if the user is authenticated with the API, `false` otherwise.
    var isAuthenticated: Bool { get }
    /// The current user's details, if applicable.
    var user: UserDetails? { get set }
    var token: FetchTokenResponse? { get set }
    var userID: String? { get set }
    var isOnboardingCompleted: Bool { get set }
    
    /// Handle an application specific URL using the appropriate authentication mechanism.
    /// - Parameter url: the application specific URL.
    /// - Parameter options: any options received with the request to open the URL.
    static func handle(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
    
    /// Get or renew the access token for the currently logged in user.
    /// - Parameter completion: a completion handler, which will receive an optional String containing the access token, or an error.
    func getAccessToken(completion: @escaping SessionTokenCompletion)
    
    /// Perform interactive authentication, beginning from the specified view controller.
    /// - Parameters:
    ///   - presenter: the view controller hosting the authentication operation.
    ///   - completion: a completion handler for success or failure of the authentication operation.
    func authenticate(from presenter: UIViewController, completion: @escaping SessionAuthenticationCompletion) throws
    
    /// Perform a logout on the authentication provider. Note this may be interactive due to the use of OAUTH.
    /// - Parameters:
    ///   - presenter: the view controller hosting the logout operation.
    ///   - completion: a completion handler for success or failure of the logout operation.
    func logout(completion: @escaping (Error?) -> Void)
    
    /// Clear any cached credentials from the device, forcing a full multi-factor process on the next authentication.
    func clearCredentials()
    
    /// The default initializer.
    /// - Parameter configuration: authentication configuration settings.
    init(configuration: SessionConfiguration)
    
    /// Perform a reset password on the authentication provider with using async/await.
    /// - Parameters:
    ///   - email: email of user, where Auth0 with send reset-password email.
    func resetPassword(email: String) async throws
    
    /// Perform a reset password on the authentication provider.
    /// - Parameters:
    ///   - email: email of user, where Auth0 with send reset-password email.
    ///   - completion: a completion handler for success or failure of the logout operation.
    func resetPassword(email: String, completion: @escaping (Error?) -> Void)
    
    /// Perform a renew of a user data.
    func updateUserData()
}

public extension SessionType {
    static func handle(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        _ = url
        _ = options
        
        return false
    }
    
    func resetPassword(email: String) async throws { }
    
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) { }
}
