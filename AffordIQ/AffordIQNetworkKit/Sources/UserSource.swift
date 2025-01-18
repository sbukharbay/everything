//
//  UserSource.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 06/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol UserSource {
    func getUserDetails(userID: String) async throws -> UserRegistrationData
    
    @discardableResult
    func completeOnboarding(userID: String) async throws -> UserStatusResponse
    
    @discardableResult
    func getUserStatus(userID: String) async throws -> UserStatusResponse
    
    func getUserID(externalID: String) async throws -> ExternalIdentityProviderResponse
    
    func getAuth0User(userID: String) async throws -> Auth0UserResponse
    
    func checkIfUsernameExists(username: String) async throws -> UsernameExistsResponse
    
    @discardableResult
    func setUserAgree(model: RMTerms) async throws -> BaseResponse
    @discardableResult
    func updateUser(userID: String, model: RMPatchUser) async throws -> CreateUserResponse
    
    func createUser(model: RMCreateUser) async throws -> CreateUserResponse
    
    @discardableResult
    func deleteUser(userID: String) async throws -> BaseResponse
}

public final class UserService: AdaptableNetwork<UserRouter>, UserSource {
    public func getUserDetails(userID: String) async throws -> UserRegistrationData {
        try await request(UserRegistrationData.self, from: .getUserDetails(userID: userID))
    }
    
    public func completeOnboarding(userID: String) async throws -> UserStatusResponse {
        try await request(UserStatusResponse.self, from: .completeOnboarding(userID: userID))
    }
    
    public func getUserStatus(userID: String) async throws -> UserStatusResponse {
        try await request(UserStatusResponse.self, from: .getUserStatus(userID: userID))
    }
    
    public func getUserID(externalID: String) async throws -> ExternalIdentityProviderResponse {
        try await request(ExternalIdentityProviderResponse.self, from: .getUserID(externalID: externalID))
    }
    
    public func getAuth0User(userID: String) async throws -> Auth0UserResponse {
        try await request(Auth0UserResponse.self, from: .getAuth0User(userID: userID))
    }
    
    public func checkIfUsernameExists(username: String) async throws -> UsernameExistsResponse {
        try await request(UsernameExistsResponse.self, from: .checkIfUsernameExists(username: username))
    }
    
    public func updateUser(userID: String, model: RMPatchUser) async throws -> CreateUserResponse {
        try await request(CreateUserResponse.self, from: .updateUser(userID: userID, model: model))
    }
    
    public func createUser(model: RMCreateUser) async throws -> CreateUserResponse {
        try await request(CreateUserResponse.self, from: .createUser(model: model))
    }
    
    public func deleteUser(userID: String) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .deleteUser(userID: userID))
    }
    
    public func setUserAgree(model: RMTerms) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .setUserAgree(model: model))
    }
}
