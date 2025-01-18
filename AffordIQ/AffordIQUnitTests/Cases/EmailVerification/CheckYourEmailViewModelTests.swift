//
//  CheckYourEmailViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 10.10.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQFoundation
@testable import AffordIQUI
@testable import AffordIQNetworkKit

final class CheckYourEmailViewModelTests: XCTestCase {
    var sut: CheckYourEmailViewModel!
    var userServiceMock: UserServiceMock!
    var loginServiceMock: LoginServiceMock!
    var userSession: SessionType!
    
    override func setUp() {
        super.setUp()
        
        let data = UserRegistrationData(dateOfBirth: "", firstName: "", lastName: "", mobilePhone: "", username: "")
        userServiceMock = UserServiceMock()
        loginServiceMock = LoginServiceMock()
        userSession = UserSessionMock.getMock()
        
        sut = CheckYourEmailViewModel(session: userSession,
                                      data: data, 
                                      userSource: userServiceMock,
                                      loginSource: loginServiceMock)
    }
    
    override func tearDown() {
        sut = nil
        
        userSession = nil
        userServiceMock = nil
        loginServiceMock = nil
        
        super.tearDown()
    }
    
    // MARK: - Testing
    func test_checkCurrentState_didOpenAcceptTerm() async {
        // given
        let userID = "acceptTerm"
        
        // when
        await sut.checkCurrentState(id: userID)
        
        // then
        XCTAssertTrue(sut.showTermsView)
    }
    
    func test_checkCurrentState_showNext() async {
        // given
        let userID = "UserID"
        
        // when
        await sut.checkCurrentState(id: userID)
        
        // then
        XCTAssertTrue(sut.showNext)
    }
    
    func test_checkCurrentState_didThrowError() async {
        // given
        let userID = "Error"
        
        // when
        await sut.checkCurrentState(id: userID)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_checkIfEmailConfirmed_didOpenAcceptTerm() async {
        // given
        let userID = "acceptTerm"
        
        // when
        await sut.checkIfEmailConfirmed(userID: userID)
        
        // then
        XCTAssertTrue(sut.showTermsView)
    }
    
    func test_checkIfEmailConfirmed_didNonConfirm() async {
        // given
        let userID = "showCheckEmailView"
        
        // when
        await sut.checkIfEmailConfirmed(userID: userID)
        
        // then
        XCTAssertTrue(sut.showError)
    }
    
    func test_checkIfEmailConfirmed_didThrowError() async {
        // given
        let userID = "Error"
        
        // when
        await sut.checkIfEmailConfirmed(userID: userID)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_getUserID_didGetUserID() async {
        // given
        userSession.userID = "userID"
        
        // when
        await sut.getUserId()
        
        // then
        XCTAssertNotNil(sut.isLoading)
    }
    
    func test_getToken_didThrowError() async {
        // when
        await sut.getToken()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_emailConfirmed_checkIfEmailConfirmedCalled() async {
        // given
        userSession.userID = "acceptTerm"
        
        // when
        await sut.emailConfirmed()
        
        // then
        XCTAssertTrue(sut.showTermsView)
    }
    
    func test_emailConfirmed_getTokenCalled() async {
        // given
        userSession.userID = nil
        
        // when
        await sut.emailConfirmed()
        
        // then
        XCTAssertTrue(loginServiceMock.getTokenCalled)
    }
}
