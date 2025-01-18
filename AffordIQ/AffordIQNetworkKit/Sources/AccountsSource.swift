//
//  AccountsSource.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 04.05.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol AccountsSource {
    func getInstitutionAccounts(userID: String, institutionID: String) async throws -> InstitutionAccountsResponse
    
    func getAccounts(userID: String) async throws -> AccountsResponse
    
    @discardableResult
    func link(model: RMLinkAccounts) async throws -> LinkAccountsResponse
}

public final class AccountsService: AdaptableNetwork<AccountsRouter>, AccountsSource {
    public func getInstitutionAccounts(userID: String, institutionID: String) async throws -> InstitutionAccountsResponse {
        try await request(InstitutionAccountsResponse.self, from: .getInstitutionAccounts(userID: userID, institutionID: institutionID))
    }
    
    public func getAccounts(userID: String) async throws -> AccountsResponse {
        try await request(AccountsResponse.self, from: .getAccounts(userID: userID))
    }
    
    public func link(model: RMLinkAccounts) async throws -> LinkAccountsResponse {
        try await request(LinkAccountsResponse.self, from: .link(model: model))
    }
}
