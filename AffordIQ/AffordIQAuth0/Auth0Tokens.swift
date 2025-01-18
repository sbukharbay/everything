//
//  Auth0Tokens.swift
//  AffordIQAuth0
//
//  Created by Sultangazy Bukharbay on 24/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Auth0
import Foundation
import LocalAuthentication

struct Auth0Tokens: Codable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "acc"
        case refreshToken = "ref"
        case idToken = "id"
    }

    let accessToken: String?
    let refreshToken: String?
    let idToken: String?
}

extension Auth0Tokens {
    static func from(data: Data) throws -> Auth0Tokens {
        let decoder = JSONDecoder()
        return try decoder.decode(Auth0Tokens.self, from: data)
    }

    func data() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

extension Auth0Tokens {
    private static func biometricKey(clientId: String) -> String {
        return clientId + "_A0B"
    }

    func storeBiometricData(clientId: String) throws {
        let data = try self.data()
        let key = Auth0Tokens.biometricKey(clientId: clientId)

        #if targetEnvironment(simulator)
        UserDefaults.standard.set(data.base64EncodedString(), forKey: key)
        #else
        try Biometrics.set(data: data, for: key)
        #endif
    }

    static func clearBiometricData(clientId: String) throws {
        let key = Auth0Tokens.biometricKey(clientId: clientId)
        #if targetEnvironment(simulator)
        UserDefaults.standard.removeObject(forKey: key)
        #else
        try Biometrics.clear(key: key)
        #endif
    }

    static func biometricDataExists(clientId: String) -> Bool {
        let key = Auth0Tokens.biometricKey(clientId: clientId)
        #if targetEnvironment(simulator)
        return UserDefaults.standard.object(forKey: key) != nil
        #else
        let result = try? Biometrics.keyExists(key)

        return result ?? false
        #endif
    }

    private static func biometricAuthenticationComplete(context: LAContext, clientId: String, ok: Bool, error: Error?, completion: @escaping (Auth0Tokens?, Error?) -> Void) {
        asyncIfRequired {
            if ok {
                do {
                    if let data = try Biometrics.getData(key: biometricKey(clientId: clientId), context: context, prompt: nil) {
                        let tokens = try Auth0Tokens.from(data: data)

                        completion(tokens, nil)
                        return
                    }
                } catch {
                    completion(nil, error)
                    return
                }
            }

            completion(nil, error)
        }
    }

    private static func retrieveTokens(clientId: String, localizedReason: String, context: LAContext, completion: @escaping (Auth0Tokens?, Error?) -> Void) {
        do {
            let accessControl = try Biometrics.accessControl()
            context.evaluateAccessControl(accessControl,
                                          operation: .useItem,
                                          localizedReason: localizedReason) { ok, error in

                biometricAuthenticationComplete(context: context, clientId: clientId, ok: ok, error: error, completion: completion)
            }
        } catch let accessError {
            completion(nil, accessError)
        }
    }

    static func biometricAuthentication(clientId: String, completion: @escaping (Auth0Tokens?, Error?) -> Void) {
        #if targetEnvironment(simulator)
        asyncAlways {
            if let tokenString = UserDefaults.standard.object(forKey: Auth0Tokens.biometricKey(clientId: clientId)) as? String,
               let tokenData = Data(base64Encoded: tokenString),
               let tokens = try? Auth0Tokens.from(data: tokenData) {
                completion(tokens, nil)
                return
            }

            completion(nil, SessionError.offlineSessionExpired)
        }
        #else
        Biometrics.checkBiometryState { success, error in

            guard success else {
                completion(nil, error)
                return
            }

            let localizedReason = NSLocalizedString("Log in to AffordIQ", bundle: Bundle(for: Auth0Session.self), comment: "Log in to AffordIQ")

            let context = LAContext()
            context.localizedFallbackTitle = NSLocalizedString("Use Password", bundle: Bundle(for: Auth0Session.self), comment: "Use Password")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason) { ok, error in

                if ok {
                    retrieveTokens(clientId: clientId,
                                   localizedReason: localizedReason,
                                   context: context,
                                   completion: completion)
                } else {
                    biometricAuthenticationComplete(context: context, clientId: clientId, ok: ok, error: error, completion: completion)
                }
            }
        }
        #endif
    }
}
