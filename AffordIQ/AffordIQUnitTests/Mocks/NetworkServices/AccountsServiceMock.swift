//
//  AccountsServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 24/08/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class AccountsServiceMock: AccountsSource {
    func getInstitutionAccounts(userID: String, institutionID: String) async throws -> AffordIQFoundation.InstitutionAccountsResponse {
        if institutionID != "error" {
            return InstitutionAccountsResponse(description: "", errors: nil, message: nil, statusCode: 200, institutionAccounts: [], openBankingConsents: [])
        } else {
            throw NetworkError.badID
        }
    }
    
    func getAccounts(userID: String) async throws -> AffordIQFoundation.AccountsResponse {
        switch userID {
        case "reconsent":
            return AccountsResponse(
                description: "",
                errors: [],
                message: "",
                statusCode: 200,
                institutionAccounts: [
                    InstitutionAccount(
                        institutionId: "mock",
                        accountId: "",
                        accountNumber: AccountNumber(
                            iban: "",
                            number: "",
                            sortCode: "",
                            swiftBic: ""
                        ),
                        accountType: InstitutionAccount.AccountType.current,
                        balance: nil,
                        displayName: nil,
                        providerDisplayName: "",
                        lastUpdated: nil,
                        providerLogoUri: "",
                        usedForDeposit: true
                    )
                ],
                openBankingConsents: [
                    OpenBankingConsent(
                        providerId: "mock",
                        consentStatus: OpenBankingConsent.ConsentStatus.authorized,
                        consentStatusUpdate: Date(),
                        consentCreated: Date(),
                        consentExpires: Date(),
                        consentScopes: [])
                ]
            )
        case "error":
            throw NetworkError.badID
        default:
            return AccountsResponse(
                description: "",
                errors: [],
                message: "",
                statusCode: 200,
                institutionAccounts: [
                    InstitutionAccount(
                        institutionId: "",
                        accountId: "",
                        accountNumber: AccountNumber(
                            iban: "",
                            number: "",
                            sortCode: "",
                            swiftBic: ""
                        ),
                        accountType: InstitutionAccount.AccountType.current,
                        balance: nil,
                        displayName: nil,
                        providerDisplayName: "",
                        lastUpdated: nil,
                        providerLogoUri: "",
                        usedForDeposit: true
                    )
                ],
                openBankingConsents: [
                    OpenBankingConsent(
                        providerId: "",
                        consentStatus: OpenBankingConsent.ConsentStatus.authorized,
                        consentStatusUpdate: Date(),
                        consentCreated: Date(),
                        consentExpires: Date(),
                        consentScopes: [])
                ]
            )
        }
    }
    
    func link(model: AffordIQFoundation.RMLinkAccounts) async throws -> AffordIQFoundation.LinkAccountsResponse {
        throw NetworkError.badID
    }
}
