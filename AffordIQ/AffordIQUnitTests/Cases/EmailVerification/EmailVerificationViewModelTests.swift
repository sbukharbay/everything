//
//  EmailVerificationViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 27/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQFoundation
@testable import AffordIQUI
@testable import AffordIQNetworkKit

class EmailVerificationViewModelTests: XCTestCase {
    var sut: EmailVerificationViewModel!
    var userServiceMock: UserServiceMock!
    var loginServiceMock: LoginServiceMock!
    var userSession: SessionType!
    
    override func setUp() {
        super.setUp()
        
        let data = UserRegistrationData(dateOfBirth: "", firstName: "", lastName: "", mobilePhone: "", username: "")
        userServiceMock = UserServiceMock()
        loginServiceMock = LoginServiceMock()
        userSession = UserSessionMock.getMock()
        
        sut = EmailVerificationViewModel(session: userSession,
                                         userSource: userServiceMock,
                                         loginSource: loginServiceMock,
                                         data: data)
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
    
//    func test_checkCurrentState_didOpenCheckEmailView() async {
//        // given
//        let userID = "showCheckEmailView"
//        
//        // when
//        await sut.checkCurrentState(id: userID)
//        
//        // then
//        XCTAssertTrue(sut.showCheckEmailView)
//    }
    
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
    
    func test_checkIfEmailConfirmed_didOpenCheckEmailView() async {
        // given
        let userID = "showCheckEmailView"
        
        // when
        await sut.checkIfEmailConfirmed(userID: userID)
        
        // then
        XCTAssertTrue(sut.showCheckEmailView)
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
        let externalID = "externalID"
        
        // when
        await sut.getUserID(externalID)
        
        // then
        XCTAssertEqual(userSession.userID, "userID")
    }
    
    func test_getUserID_didThrowError() async {
        // given
        let externalID = "Error"
        
        // when
        await sut.getUserID(externalID)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_checkUserID_checkIfEmailConfirmedCalled() async {
        // given
        userSession.userID = "userID"
        
        // when
        await sut.checkUserID()
        
        // then
        XCTAssertTrue(sut.showCheckEmailView)
    }
    
    func test_checkUserID_getUserIDCalled() async {
        // given
        userSession.userID = "auth0|userID"
        
        // when
        await sut.checkUserID()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_checkUserID_withExternalID_checkIfEmailConfirmedCalled() async {
        // given
        userSession.userID = "notAcceptTerm"
        
        // when
        await sut.checkUserID()
        
        // then
        XCTAssertTrue(sut.showCheckEmailView)
    }
    
    func test_getToken_didThrowError() async {
        // when
        await sut.getToken()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_emailConfirmed_checkIfEmailConfirmedCalled() async {
        // given
        userSession.userID = "something"
        
        // when
        await sut.emailConfirmed()
        
        // then
        XCTAssertTrue(sut.showCheckEmailView)
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
