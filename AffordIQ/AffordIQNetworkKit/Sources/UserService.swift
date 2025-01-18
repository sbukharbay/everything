//
//  UserService.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 06/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQAPI

public protocol UserSource {
    func getUserDetails(userID: String) async throws -> UserRegistrationData
    func getUserStatus(userID: String) async throws -> UserStatusResponse
}

public final class UserService: AdaptableNetwork<UserRouter>, UserSource {
    public func getUserDetails(userID: String) async throws -> UserRegistrationData {
        try await request(UserRegistrationData.self, from: .getUserDetails(userID: userID))
    }
    
    public func getUserStatus(userID: String) async throws -> UserStatusResponse {
        try await request(UserStatusResponse.self, from: .getUserStatus(userID: userID))
    }
}
