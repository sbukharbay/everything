//
//  UserSessionMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 27/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import UIKit
@testable import AffordIQFoundation

class UserSessionMock: SessionType {
    var isAuthenticated: Bool = false
    var user: UserDetails? = UserDetailsMock.getMock()
    var token: FetchTokenResponse? = FetchTokenResponse(accessToken: "mockToken", expiresIn: 0, tokenType: "")
    var userID: String?
    var isOnboardingCompleted: Bool = false
    
    static func handle(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return true
    }
    
    func logout(completion: @escaping (Error?) -> Void) {
        
    }
    
    func getAccessToken(completion: @escaping SessionTokenCompletion) {
        
    }
    
    func authenticate(from presenter: UIViewController, completion: @escaping SessionAuthenticationCompletion) throws {
        
    }
    
    func logout(from presenter: UIViewController, completion: @escaping (Error?) -> Void) {
        
    }
    
    func clearCredentials() {
        
    }
    
    required init(configuration: SessionConfiguration) {
        
    }
    
    func updateUserData() {
        
    }
    
    static func getMock() -> UserSessionMock {
        UserSessionMock(
            configuration: SessionConfiguration(clientId: "", issuer: "", scopes: [], redirectUri: "", logoutRedirectUri: "", audienceUri: "", webClientSecret: "", webClientId: "", webGrantType: "")
        )
    }
    
    func resetPassword(email: String) async throws {
        
    }
}
