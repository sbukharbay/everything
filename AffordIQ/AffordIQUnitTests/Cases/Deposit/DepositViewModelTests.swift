//
//  DepositViewModelTests.swift
//  AffordIQ
//
//  Created by Sultangazy Bukharbay on 14.12.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class DepositViewModelTests: XCTestCase {
    var sut: DepositViewModel!
    private var depositSourceMock: DepositServiceMock!
    private var userSessionMock: UserSessionMock!
    private var depositViewMock: DepositViewMock!
    private var userServiceMock: UserServiceMock!
    private var accountsSourceMock: AccountsServiceMock!
    
    override func setUp() {
        super.setUp()
        
        depositSourceMock = DepositServiceMock()
        userSessionMock = UserSessionMock.getMock()
        userSessionMock.userID = "userID"
        depositViewMock = DepositViewMock()
        userServiceMock = UserServiceMock()
        accountsSourceMock = AccountsServiceMock()
        
        sut = DepositViewModel(view: depositViewMock, userSession: userSessionMock, accountsSource: accountsSourceMock, depositSource: depositSourceMock, userSource: userServiceMock)
    }
    
    override func tearDown() {
        sut = nil
        depositSourceMock = nil
        userSessionMock = nil
        depositViewMock = nil
        accountsSourceMock = nil
        userServiceMock = nil
        super.tearDown()
    }

    func test_deleteOutsideCapital() async {
        // given
        userSessionMock.userID = "userID"
        
        // when
        await sut.deleteOutsideCapital()
        
        // then
        XCTAssertTrue(depositSourceMock.deletedExternalCapital)
    }
    
    func test_deleteOutsideCapital_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.deleteOutsideCapital()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_updateAccounts() async {
        // given
        userSessionMock.userID = "userID"
        let expectation = XCTestExpectation(description: #function)
        
        // when
        await sut.updateAccounts(contributesToDeposit: [], doesNotContributeToDeposit: []) { _ in
            expectation.fulfill()
        }
        
        // then
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    func test_updateAccounts_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.updateAccounts(contributesToDeposit: [], doesNotContributeToDeposit: []) { _ in }
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_confirm() async {
        // when
        await sut.confirm()
        
        // then
        XCTAssertTrue(depositViewMock.presentedNext)
    }
    
    func test_confirm_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.confirm()
        
        // then
        XCTAssertNotNil(sut.error)
    }
}
