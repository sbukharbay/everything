//
//  Auth0Session.swift
//  AffordIQAPI
//
//  Created by Sultangazy Bukharbay on 22/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Auth0
import LocalAuthentication
import UIKit

public final class Auth0Session: NSObject {
    let configuration: SessionConfiguration
    let renewalQueue: DispatchQueue = .init(label: "com.blackarrowgroup.renewal", qos: .default, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    let isRenewing = DispatchSemaphore(value: 0)

    let authentication: Auth0.Authentication
    var credentials: Auth0.Credentials?
    var profile: Auth0UserDetails?
    public var accessToken: FetchTokenResponse?
    public var id: String?
    public var onboardingComplete = false
    public var isAuthenticated = false
    public static let shared = Auth0Session(configuration: Environment.shared.sessionConfiguration)

    public required init(configuration: SessionConfiguration) {
        self.configuration = configuration

        authentication = Auth0.authentication(clientId: configuration.clientId, domain: configuration.issuer)

        super.init()
    }
}

extension SessionError {
    static func from(_ error: Auth0.WebAuthError) -> SessionError? {
        switch error {
        case .userCancelled:
            return .cancelled
        default:
            break
        }

        return .other(error: error)
    }
}

public extension Auth0Session {
    func retrieveProfile(completion: @escaping SessionAuthenticationCompletion) {
        guard let accessToken = credentials?.accessToken else {
            asyncIfRequired {
                completion(false, SessionError.other(error: CredentialsManagerError.noCredentials))
            }
            return
        }
        
        if let credentials {
            Auth0Session.shared.accessToken = FetchTokenResponse(
                accessToken: credentials.accessToken,
                expiresIn: Int(credentials.expiresIn.timeIntervalSince1970 - Date().timeIntervalSince1970),
                tokenType: credentials.tokenType)
        }
        
        authentication
            .userInfo(withAccessToken: accessToken)
            .start { [weak self] result in
                switch result {
                case let .success(profile):
                    self?.profile = Auth0UserDetails(profile: profile)

                    asyncIfRequired {
                        completion(true, nil)
                    }
                case let .failure(error):
                    asyncIfRequired {
                        completion(false, SessionError.other(error: error))
                    }
                }
            }
    }

    func processAuthenticationError(error: Error, completion: @escaping SessionAuthenticationCompletion) {
        asyncIfRequired {
            if let auth0Error = error as? Auth0.WebAuthError {
                completion(false, SessionError.from(auth0Error))
            } else {
                completion(false, SessionError.other(error: error))
            }
        }
    }

    func fallback(completion: @escaping SessionAuthenticationCompletion) {
        asyncAfter(.milliseconds(500)) { [weak self] in
            self?.authenticateOnline(completion: completion)
        }
    }

    func handleOfflineAuthentication(refreshToken: String?, error: Error?, completion: @escaping SessionAuthenticationCompletion) {
        if let error = error {
            if case SessionError.offlineSessionExpired = error {
                clearCredentials()
                fallback(completion: completion)
                return
            } else {
                let nsError = error as NSError
                if nsError.domain == kLAErrorDomain {
                    switch Int32(nsError.code) {
                    case kLAErrorUserFallback:
                        fallback(completion: completion)
                        return

                    case kLAErrorSystemCancel, kLAErrorAppCancel, kLAErrorUserCancel:
                        completion(false, SessionError.cancelled)
                        return

                    default:
                        break
                    }
                }
            }
        }

        guard let refreshToken = refreshToken, !refreshToken.isEmpty else {
            clearCredentials()
            fallback(completion: completion)
            return
        }

        authentication
            .renew(withRefreshToken: refreshToken, scope: configuration.scopes.joined(separator: " "))
            .start { [weak self] result in

                switch result {
                case let .success(credentials):
                    _ = self?.store(credentials: credentials)
                    self?.isAuthenticated = true
                    self?.retrieveProfile(completion: completion)
                case let .failure(error):
                    self?.processAuthenticationError(error: error, completion: completion)
                }
            }
    }

    func authenticateOfflineIfPossible(completion: @escaping SessionAuthenticationCompletion) {
        if !Auth0Tokens.biometricDataExists(clientId: configuration.clientId) {
            authenticateOnline(completion: completion)
            return
        }

        Auth0Tokens.biometricAuthentication(clientId: configuration.clientId) { [weak self] tokens, error in

            self?.handleOfflineAuthentication(refreshToken: tokens?.refreshToken, error: error, completion: completion)
        }
    }

    func authenticateOnline(completion: @escaping SessionAuthenticationCompletion) {
        let audience = configuration.audienceUri

        Auth0
            .webAuth(clientId: configuration.clientId, domain: configuration.issuer)
            .useEphemeralSession()
            .scope(configuration.scopes.joined(separator: " "))
            .audience(audience)
            .start { [weak self] result in

                switch result {
                case let .success(credentials):
                    _ = self?.store(credentials: credentials)
                    self?.isAuthenticated = true
                    self?.retrieveProfile(completion: completion)
                case let .failure(error):
                    self?.processAuthenticationError(error: error, completion: completion)
                }
            }
    }
}
