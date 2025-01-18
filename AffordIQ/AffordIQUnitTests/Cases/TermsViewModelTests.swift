//
//  TermsViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 28/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQNetworkKit
@testable import AffordIQUI

class TermsViewModelTests: XCTestCase {
    var sut: TermsViewModel!
    var userServiceMock: UserServiceMock!
    var notificationServiceMock: NotificationServiceMock!
    var userSessionMock: UserSessionMock!
    
    override func setUp() {
        super.setUp()
        
        userServiceMock = UserServiceMock()
        notificationServiceMock = NotificationServiceMock()
        userSessionMock = UserSessionMock.getMock()
        sut = TermsViewModel(userSession: userSessionMock,
                             notificationSource: notificationServiceMock,
                             userSource: userServiceMock)
    }
    
    override func tearDown() {
        sut = nil
        notificationServiceMock = nil
        userSessionMock = nil
        userServiceMock = nil
        
        super.tearDown()
    }
    
    // MARK: - Testing
    func test_checkCurrentState_showGetStartedCalled() async {
        // given
        sut.userID = "UserID"
        
        // when
        await sut.checkCurrentState()
        
        // then
        XCTAssertTrue(userServiceMock.showGetStartedCalled)
    }
    
    func test_checkCurrentState_didThrowError() async {
        // given
        sut.userID = nil
        
        // when
        await sut.checkCurrentState()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_setUserAgree_didThrowError() async {
        // given
        sut.userID = nil
        
        // when
        await sut.setUserAgree()
        
        // then
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_setUserAgree_checkCurrentStateCalled() async {
        // given
        sut.userID = "UserID"
        
        // when
        await sut.setUserAgree()
        
        // then
        XCTAssertTrue(userServiceMock.termsAccepted)
    }
    
    func test_registerDevice_didThrowError() async {
        // given
        sut.userID = nil
        
        // when
        await sut.registerDevice()
        
        // then
        XCTAssertEqual(sut.error as? NetworkError, .badID)
    }
    
    func test_registerDevice_didRegisterDevice() async {
        // given
        sut.userID = "notNil"
        
        // when
        await sut.registerDevice()
        
        // then
        XCTAssertTrue(notificationServiceMock.didDeviceRegister)
    }
    
    func test_getUserID_isRightUserID() async {
        // given
        let externalUserID = "externalID"
        
        // when
        let returnedUserID = await sut.getUserID(with: externalUserID)
        
        // then
        XCTAssertEqual(returnedUserID, "userID")
    }
    
    func test_getUserID_didThrowError() async {
        // given
        let externalUserID = "error"
        
        // when
        let returnedUserID = await sut.getUserID(with: externalUserID)
        
        // then
        XCTAssertNil(returnedUserID)
        XCTAssertEqual(sut.error as? NetworkError, .badID)
    }
    
    func test_getUserID_userSessionIDNotNil_isUserIDsEqual() async {
        // given
        userSessionMock.userID = "userID"
        
        // when
        await sut.getUserID()
        
        // then
        XCTAssertEqual(sut.userID, userSessionMock.userID)
    }
    
    func test_getUserID_externalUserIDNotNil_getUserIDCalled() async {
        // given
        let externalUserID = "externalID"
        userSessionMock.userID = nil
        userSessionMock.user?.externalUserId = externalUserID
        
        // when
        await sut.getUserID()
        
        // then
        XCTAssertEqual(sut.userID, "userID")
    }
}
