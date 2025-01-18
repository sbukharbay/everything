//
//  AuthManager.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 16/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQAuth0
import AffordIQFoundation

final actor AuthManager {
    static let shared = AuthManager()
    private var refreshTask: Task<FetchTokenResponse, Error>?
    private let service: LoginSource = LoginService()
    
    private init() {}
    
    func validToken() async throws -> FetchTokenResponse {
        if let refreshTask {
            return try await refreshTask.value
        }
        
        guard let token = Auth0Session.shared.accessToken else {
            throw AuthError.missingToken
        }
        
        if !token.isExpired {
            return token
        }
        
        return try await refreshToken()
    }
    
    func refreshToken() async throws -> FetchTokenResponse {
        if let refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task { () throws -> FetchTokenResponse in
            defer { refreshTask = nil }
            
            let fetchTokenModel = RMFetchToken(
                clientId: Environment.shared.sessionConfiguration.webClientId,
                clientSecret: Environment.shared.sessionConfiguration.webClientSecret,
                audience: Environment.shared.sessionConfiguration.audienceUri,
                grantType: Environment.shared.sessionConfiguration.webGrantType
            )
            
            let newToken = try await service.fetchToken(fetchTokenModel)
            Auth0Session.shared.accessToken = newToken
            
            return newToken
        }
        
        self.refreshTask = task
        
        return try await task.value
    }
}
