//
//  UserServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 27/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class UserServiceMock: UserSource {
    var showGetStartedCalled: Bool = false
    var termsAccepted: Bool = false
    var didGetUserDetailsCall: Bool = false
    
    func setUserAgree(model: RMTerms) async throws -> BaseResponse {
        if model.userID == "error" {
            throw NetworkError.badID
        } else {
            termsAccepted = true
            showGetStartedCalled = true
            return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
        }
    }
    
    func getUserDetails(userID: String) async throws -> UserRegistrationData {
        if userID == "error" {
            throw NetworkError.unauthorized
        } else {
            didGetUserDetailsCall = true
            return UserRegistrationData(dateOfBirth: "", firstName: "", lastName: "", mobilePhone: "", username: "alfi")
        }
    }
    
    func completeOnboarding(userID: String) async throws -> UserStatusResponse {
        if userID == "move" {
            return UserStatusResponse(description: "", errors: nil, message: "", statusCode: 200, email: "", nextStep: .linkBankAccounts)
        }
        throw NetworkError.badID
    }
    
    func getUserStatus(userID: String) async throws -> UserStatusResponse {
        if userID == "acceptTerm" {
            return UserStatusResponse(description: "", errors: [], message: "", statusCode: 200, email: "", nextStep: .acceptTerms)
        } else if userID == "Error" {
            throw NetworkError.badID
        } else if userID == "UserID" {
            showGetStartedCalled = true
            return UserStatusResponse(description: "", errors: [], message: "", statusCode: 200, email: "", nextStep: .linkBankAccounts)
        } else {
            return UserStatusResponse(description: "", errors: [], message: "", statusCode: 200, email: "", nextStep: .addIncomeInfo)
        }
    }
    
    func getUserID(externalID: String) async throws -> ExternalIdentityProviderResponse {
        if externalID == "externalID" || externalID == "auth0|UserID" {
            return ExternalIdentityProviderResponse(description: "", errors: [], userID: "userID", message: "", statusCode: 200)
        } else {
            throw NetworkError.badID
        }
    }
    
    func getAuth0User(userID: String) async throws -> Auth0UserResponse {
        if userID == "acceptTerm" {
            return Auth0UserResponse(description: "", errors: [], message: "", statusCode: 200, emailVerified: true)
        } else if userID == "Error" {
            throw NetworkError.badID
        } else {
            return Auth0UserResponse(description: "", errors: [], message: "", statusCode: 200, emailVerified: false)
        }
    }
    
    func checkIfUsernameExists(username: String) async throws -> UsernameExistsResponse {
        if username == "throw" {
            throw NetworkError.badID
        } else if username == "error" {
            return UsernameExistsResponse(description: "", errors: [], exists: true, message: "", statusCode: 200)
        } else {
            return UsernameExistsResponse(description: "", errors: [], exists: false, message: "", statusCode: 200)
        }
    }
    
    func updateUser(userID: String, model: RMPatchUser) async throws -> CreateUserResponse {
        if userID.isEmpty {
            throw NetworkError.badID
        } else {
            return CreateUserResponse(description: "", errors: [], message: "", statusCode: 200, userId: "")
        }
    }
    
    func createUser(model: RMCreateUser) async throws -> CreateUserResponse {
        if model.username == "throw" {
            throw NetworkError.badID
        } else if model.username == "error" {
            return CreateUserResponse(description: "", errors: [], message: "", statusCode: 200, userId: "")
        } else {
            return CreateUserResponse(description: "", errors: [], message: "", statusCode: 200, userId: "")
        }
    }
    
    func deleteUser(userID: String) async throws -> BaseResponse {
        if userID == "delete" {
            throw NetworkError.badID
        } else {
            return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
        }
    }
}
