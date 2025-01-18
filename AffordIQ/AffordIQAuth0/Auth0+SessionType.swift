//
//  Auth0+SessionType.swift
//  AffordIQAuth0
//
//  Created by Sultangazy Bukharbay on 12/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Auth0
import LocalAuthentication
import UIKit

extension Auth0Session: SessionType {
    public var isOnboardingCompleted: Bool {
        get {
            onboardingComplete
        }
        set(newValue) {
            onboardingComplete = newValue
        }
    }
    
    public var token: FetchTokenResponse? {
        get {
            return accessToken
        }
        set(newValue) {
            accessToken = newValue
        }
    }
    
    public var userID: String? {
        get {
            return id
        }
        set(newValue) {
            id = newValue
        }
    }
    
    public var user: UserDetails? {
        get {
            return profile
        }
        set {
            if let value = newValue {
                print(value)
            }
        }
    }
    
    private func handleRefresh(result: Result<Credentials, AuthenticationError>, completion: @escaping SessionTokenCompletion) {
        switch result {
        case let .success(credentials):
            self.credentials = credentials
            isAuthenticated = true
            _ = store(credentials: credentials)
            asyncIfRequired {
                completion(credentials.accessToken, nil)
            }
        case let .failure(error):
            asyncIfRequired {
                completion(nil, error)
            }
        }
    }
    
    func getOrRenewAccessToken(completion: @escaping SessionTokenCompletion) {
        if let credentials = credentials {
            let oneMinute = Date().addingTimeInterval(60.0)
            
            if credentials.expiresIn > oneMinute {
                asyncIfRequired {
                    completion(credentials.accessToken, nil)
                }
                return
            }
        }
        
        guard let refreshToken = credentials?.refreshToken else {
            completion(nil, SessionError.offlineSessionExpired)
            return
        }
        
        authentication
            .renew(withRefreshToken: refreshToken, scope: configuration.scopes.joined(separator: " "))
            .start { [weak self] result in
                self?.handleRefresh(result: result, completion: completion)
                self?.isRenewing.signal()
            }
        
        isRenewing.wait()
    }
    
    public func getAccessToken(completion: @escaping SessionTokenCompletion) {
        renewalQueue.sync { [weak self] in
            self?.getOrRenewAccessToken(completion: completion)
        }
    }
    
    func store(credentials: Auth0.Credentials) -> Bool {
        guard let refreshToken = credentials.refreshToken,
              !refreshToken.isEmpty
        else {
            clearCredentials()
            preconditionFailure()
        }
        self.credentials = credentials
        let tokens = Auth0Tokens(accessToken: credentials.accessToken,
                                 refreshToken: credentials.refreshToken,
                                 idToken: credentials.idToken)
        
        do {
            try tokens.storeBiometricData(clientId: configuration.clientId)
        } catch {
            return false
        }
        return true
    }
    
    public func authenticate(from _: UIViewController, completion: @escaping SessionAuthenticationCompletion) throws {
        authenticateOfflineIfPossible(completion: completion)
    }
    
    public func logout(completion: @escaping (Error?) -> Void) {
        clearCredentials()
        
        completion(nil)
    }
    
    public func clearCredentials() {
        accessToken = nil
        credentials = nil
        isAuthenticated = false
        isOnboardingCompleted = false
        user = nil
        try? Auth0Tokens.clearBiometricData(clientId: configuration.clientId)
    }
    
    public func resetPassword(email: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            resetPassword(email: email) { _ in
                continuation.resume()
            }
        }
    }
    
    public func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        authentication
            .resetPassword(email: email, connection: "Username-Password-Authentication")
            .start { result in
                switch result {
                case .success:
                    completion(nil)
                case let .failure(error):
                    completion(error)
                    print("Error to reset password", error)
                }
            }
    }
    
    public func updateUserData() {
        guard let accessToken = credentials?.accessToken else {
            return
        }
        
        authentication
            .userInfo(withAccessToken: accessToken)
            .start { [weak self] result in
                switch result {
                case let .success(profile):
                    self?.profile = Auth0UserDetails(profile: profile)
                case let .failure(error):
                    asyncIfRequired {
                        print("Error retrieving profile", error.debugDescription)
                    }
                }
            }
    }
}
