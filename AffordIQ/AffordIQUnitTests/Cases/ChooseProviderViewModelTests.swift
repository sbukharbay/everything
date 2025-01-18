//
//  ChooseProviderViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 05.10.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class ChooseProviderViewModelTests: XCTestCase {
    var sut: ChooseProviderViewModel!
    var obSourceMock: OpenBankingServiceMock!
    var accountsSourceMock: AccountsServiceMock!
    var userSessionMock: SessionType!
    
    override func setUp() {
        super.setUp()
        
        obSourceMock = OpenBankingServiceMock()
        accountsSourceMock = AccountsServiceMock()
        userSessionMock = UserSessionMock.getMock()
        userSessionMock.userID = "test"
        sut = ChooseProviderViewModel(openBankingSource: obSourceMock, accountsSource: accountsSourceMock, userSession: userSessionMock, getStartedType: nil)
    }
    
    override func tearDown() {
        sut = nil
        obSourceMock = nil
        accountsSourceMock = nil
        userSessionMock = nil
        super.tearDown()
    }

    func test_getProviders_didThrowError() async {
        // given
        obSourceMock.willThrowError = true
        
        // when
        await sut.getProviders()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_setAuthorised() async {
        // when
        await sut.setAuthorised(request: RMAuthoriseBank(code: "code", scope: "info", state: "state", providerID: "mock"), institutionID: "mock")
        
        // then
        XCTAssertNotNil(sut.selectFrom)
    }
    
    func test_setAuthorised_didThrowError() async {
        // when
        await sut.setAuthorised(request: RMAuthoriseBank(code: "error", scope: "info", state: "state", providerID: "mock"), institutionID: "mock")
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_getAccounts_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.getAccounts("error")
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_filter() {
        // when
        sut.filter(with: "")
        
        // then
        XCTAssertNotNil(sut.presentProviders)
    }
}
