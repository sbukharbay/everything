//
//  Biometrics.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 03/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import LocalAuthentication

public struct Biometrics {
    public enum BiometryState {
        case available
        case locked
        case unavailable
    }

    public static var currentState: BiometryState {
        let context = LAContext()
        var error: NSError?

        let canEvaluatePolicy = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)

        if let error = error as? LAError,
           error.code == LAError.Code.biometryLockout {
            return .locked
        }

        return canEvaluatePolicy ? .available : .unavailable
    }

    public static func accessControl() throws -> SecAccessControl {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?

        access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .biometryCurrentSet, &error)

        if let access = access {
            return access
        }

        if let error = error?.takeRetainedValue() {
            throw error
        }

        fatalError("Unknown error.")
    }

    public static func set(data: Data, for key: String) throws {
        let accessControl = try self.accessControl()

        try clear(key: key)

        let query: NSDictionary = [kSecClass as String: kSecClassGenericPassword as String,
                                   kSecAttrAccount as String: key,
                                   kSecAttrAccessControl as String: accessControl,
                                   kSecValueData as String: data]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != noErr {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
    }

    public static func clear(key: String) throws {
        let deleteQuery: NSDictionary = [kSecClass as String: kSecClassGenericPassword as String,
                                         kSecAttrAccount as String: key]

        let status = SecItemDelete(deleteQuery)

        if status != noErr && status != errSecItemNotFound {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
    }

    public static func keyExists(_ key: String) throws -> Bool {
        let nonInteractiveContext = LAContext()
        nonInteractiveContext.interactionNotAllowed = true
        let query: NSDictionary = [kSecClass as String: kSecClassGenericPassword as String,
                                   kSecAttrAccount as String: key,
                                   kSecUseAuthenticationContext as String: nonInteractiveContext]

        var result = false

        DispatchQueue.global(qos: .default).sync {
            var dummy: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dummy)

            switch status {
            case errSecInteractionNotAllowed, errSecSuccess:
                result = true
            case errSecAuthFailed, errSecItemNotFound:
                result = false
            default:
                result = false
            }
        }

        return result
    }

    public static func checkBiometryState(_ completion: @escaping (Bool, Error?) -> Void) {
        let currentState = self.currentState

        switch currentState {
        case .available:
            completion(true, nil)
            return

        case .unavailable:
            completion(false, nil)
            return

        case .locked:
            break
        }

        let context = LAContext()
        let reason = NSLocalizedString("Access biometric login credentials", comment: "Access biometric login credentials")

        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: { ok, error in

            asyncIfRequired {
                completion(ok, error)
            }
        })
    }

    public static func getData(key: String, context: LAContext? = nil, prompt: String? = nil) throws -> Data? {
        let accessControl = try self.accessControl()

        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true,
                                    kSecAttrAccessControl as String: accessControl,
                                    kSecMatchLimit as String: kSecMatchLimitOne]

        if let context = context {
            query[kSecUseAuthenticationContext as String] = context
            query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUISkip
        }

        if let prompt = prompt {
            query[kSecUseOperationPrompt as String] = prompt
            query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIAllow
        }

        var dataTypeRef: CFTypeRef?

        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        switch status {
        case noErr:
            return dataTypeRef as? Data

        case errSecItemNotFound:
            return nil

        default:
            break
        }

        throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
    }
}
