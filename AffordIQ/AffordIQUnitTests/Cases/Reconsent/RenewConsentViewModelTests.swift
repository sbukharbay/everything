//
//  RenewConsentViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 25.09.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class RenewConsentViewModelTests: XCTestCase {
    var sut: RenewConsentViewModel!
    
    override func setUp() {
        super.setUp()
        
        sut = RenewConsentViewModel(
            accounts: [[InstitutionAccount(
                institutionId: "institution1",
                accountId: "account1",
                accountNumber: AccountNumber(iban: "TEST", number: "1", sortCode: "code", swiftBic: "BIC"),
                accountType: .current,
                balance: AccountBalance(currentBalance: MonetaryAmount(amount: 1000), availableBalanceIncludingOverdraft: MonetaryAmount(amount: 1100), overdraft: MonetaryAmount(amount: 100), lastUpdated: Date()),
                displayName: "Current Account 1",
                providerDisplayName: "Test",
                lastUpdated: Date(),
                providerLogoUri: "logo",
                usedForDeposit: false)]], 
            type: .reconsent)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_reconsent_confirm() throws {
        // given
        sut.accounts = [
            [InstitutionAccount(
                institutionId: "institution1",
                accountId: "account1",
                accountNumber: AccountNumber(iban: "TEST", number: "1", sortCode: "code", swiftBic: "BIC"),
                accountType: .current,
                balance: AccountBalance(currentBalance: MonetaryAmount(amount: 1000), availableBalanceIncludingOverdraft: MonetaryAmount(amount: 1100), overdraft: MonetaryAmount(amount: 100), lastUpdated: Date()),
                displayName: "Current Account 1",
                providerDisplayName: "Test",
                lastUpdated: Date(),
                providerLogoUri: "logo",
                usedForDeposit: false)],
            [InstitutionAccount(
                institutionId: "institution2",
                accountId: "account2",
                accountNumber: AccountNumber(iban: "TEST", number: "2", sortCode: "code", swiftBic: "BIC"),
                accountType: .current,
                balance: AccountBalance(currentBalance: MonetaryAmount(amount: 2000), availableBalanceIncludingOverdraft: MonetaryAmount(amount: 200), overdraft: MonetaryAmount(amount: 200), lastUpdated: Date()),
                displayName: "Current Account 2",
                providerDisplayName: "Test",
                lastUpdated: Date(),
                providerLogoUri: "logo",
                usedForDeposit: false)]
        ]
        sut.renew = [true, true]
        
        // when
        sut.confirm()
        
        // then
        XCTAssertNotNil(sut.$reconsent)
    }
}
