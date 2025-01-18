//
//  OpenBankingSource.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 04.05.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol OpenBankingSource {
    func getProviders() async throws -> ProvidersResponse
    
    @discardableResult
    func authoriseCode(body: RMAuthoriseBank) async throws -> BaseResponse
    
    func authorise(userID: String, providerID: String) async throws -> BaseResponse
    
    func reconsent(userID: String, providers: ReconsentRequestModel) async throws -> OpenBankingReconsent
    
    func checkAuthStatus(of userID: String) async throws -> OpenBankingAuthoriseStatus
}

public final class OpenBankingService: AdaptableNetwork<OpenBankingRouter>, OpenBankingSource {
    public func getProviders() async throws -> ProvidersResponse {
        try await request(ProvidersResponse.self, from: .getProviders)
    }
    
    public func authoriseCode(body: RMAuthoriseBank) async throws -> BaseResponse {
        try await queryRequest(BaseResponse.self, from: .authoriseCode(request: body))
    }
    
    public func authorise(userID: String, providerID: String) async throws -> BaseResponse {
        try await queryRequest(BaseResponse.self, from: .authorise(userID: userID, providerID: providerID))
    }
    
    public func reconsent(userID: String, providers: ReconsentRequestModel) async throws -> OpenBankingReconsent {
        try await request(OpenBankingReconsent.self, from: .reconsent(userID: userID, providers: providers))
    }
    
    public func checkAuthStatus(of userID: String) async throws -> OpenBankingAuthoriseStatus {
        try await request(OpenBankingAuthoriseStatus.self, from: .checkAuthStatus(userID: userID))
    }
}
