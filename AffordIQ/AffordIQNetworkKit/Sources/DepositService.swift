//
//  DepositService.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 07/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol DepositSource {
    @discardableResult
    func confirmSavings(userID: String) async throws -> BaseResponse
    
    @discardableResult
    func deleteExternalCapital(userID: String) async throws -> BaseResponse
    
    func getExternalCapital(userID: String) async throws -> ExternalCapitalResponse
    
    @discardableResult
    func createExternalCapital(userID: String, model: RMExternalCapital) async throws -> BaseResponse
    
    @discardableResult
    func updateExternalCapital(userID: String, model: RMExternalCapital) async throws -> BaseResponse
    
    func getBalance(userID: String) async throws -> DepositBalanceResponse
    
    @discardableResult
    func updateAccounts(model: RMAccountsUsedForDeposit) async throws -> BaseResponse
}

public final class DepositService: AdaptableNetwork<DepositRouter>, DepositSource {
    public func confirmSavings(userID: String) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .confirmSavings(userID: userID))
    }
    
    public func deleteExternalCapital(userID: String) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .deleteExternalCapital(userID: userID))
    }
    
    public func getExternalCapital(userID: String) async throws -> ExternalCapitalResponse {
        try await request(ExternalCapitalResponse.self, from: .getExternalCapital(userID: userID))
    }
    
    public func createExternalCapital(userID: String, model: RMExternalCapital) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .createExternalCapital(userID: userID, model: model))
    }
    
    public func updateExternalCapital(userID: String, model: RMExternalCapital) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .updateExternalCapital(userID: userID, model: model))
    }
    
    public func getBalance(userID: String) async throws -> DepositBalanceResponse {
        try await request(DepositBalanceResponse.self, from: .getBalance(userID: userID))
    }
    
    public func updateAccounts(model: RMAccountsUsedForDeposit) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .updateAccounts(model: model))
    }
}
