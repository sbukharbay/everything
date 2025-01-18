//
//  EnterEmailViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 13/07/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
import AffordIQFoundation
import AffordIQControls
import AffordIQNetworkKit
import Combine
@testable import AffordIQUI

final class EnterEmailViewModelTests: XCTestCase {
    var sut: EnterEmailViewModel!
    var userSessionMock: UserSessionMock!
    var userSource: UserSource!
    var loginSource: LoginServiceMock!
    
    override func setUp() {
        super.setUp()
        userSessionMock = UserSessionMock.getMock()
        userSource = UserServiceMock()
        loginSource = LoginServiceMock()
        sut = EnterEmailViewModel(
            session: userSessionMock,
            userSource: userSource,
            loginSource: loginSource,
            data: UserRegistrationData.getMock()
        )
    }
    
    override func tearDown() {
        sut = nil
        userSessionMock = nil
        userSource = nil
        loginSource = nil
        super.tearDown()
    }
    
    func test_isValidEmail_isValid() {
        // given
        let email = "email@email.com"
        
        // when
        let isValid = sut.isValidEmail(email)
        
        // then
        XCTAssertTrue(isValid)
    }
    
    func test_isValidEmail_isNotValid() {
        // given
        let email = "notvalid"
        
        // when
        let isValid = sut.isValidEmail(email)
        
        // then
        XCTAssertFalse(isValid)
    }
    
    func test_isValidField_isValid() {
        // given
        let field: EmailViewField = .email
        let values: [EmailViewField: String] = [.email: "email@email.com"]
        
        // when
        let isValid = sut.isValid(field: field, values: values)
        
        // then
        XCTAssertTrue(isValid)
    }
    
    func test_isValidField_isNotValid() {
        // given
        let field: EmailViewField = .email
        let values: [EmailViewField: String] = [.email: ""]
        
        // when
        let isValid = sut.isValid(field: field, values: values)
        
        // then
        XCTAssertFalse(isValid)
    }
    
    func test_validationMessageField_isNotValidField_returnMessage() {
        // given
        let field: EmailViewField = .email
        let values: [EmailViewField: String] = [.email: ""]
        
        let message = "Please enter a valid email address."
        
        // when
        let returnedMessage = sut.validationMessage(field: field, values: values)
        
        // then
        XCTAssertEqual(message, returnedMessage)
    }
    
    func test_validationMessageField_isValidField_returnNil() {
        // given
        let field: EmailViewField = .email
        let values: [EmailViewField: String] = [.email: "email@email.com"]
        
        // when
        let returnedMessage = sut.validationMessage(field: field, values: values)
        
        // then
        XCTAssertNil(returnedMessage)
    }

    func test_textFieldShouldReturn_isValid() {
        // given
        let field: EmailViewField = .email
        let messageSetter: (String?) -> Void = { _ in }
        let messageSetters: [EmailViewField: MessageSetter] = [.email: messageSetter]
        let values: [EmailViewField: String] = [.email: "email@email.com"]
        
        // when
        let isValid = sut.textFieldShouldReturn(field: field, messageSetters: messageSetters, values: values)
        
        // then
        XCTAssertTrue(isValid)
    }
    
    func test_updateUserEmail_userNotExist_updated() async {
        // given
        let userID = "UserID"
        sut.email = "UserID"
        
        // when
        await sut.updateUserEmail(userID: userID)
        
        // then
        XCTAssertTrue(sut.showNext)
    }
    
    func test_updateUserEmail_userExist_updated() async {
        // given
        let userID = "userID"
        sut.email = "error"
        
        // when
        await sut.updateUserEmail(userID: userID)
        
        // then
        XCTAssertTrue(sut.userAlreadyExists)
    }
    
    func test_updateUserEmail_throwError() async {
        // given
        let userID = "userID"
        sut.email = "throw"
        
        // when
        await sut.updateUserEmail(userID: userID)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_getUserID_returnedUserID() async {
        // given
        let externalID = "externalID"
        
        // when
        await sut.getUserID(externalID)
        
        // then
        XCTAssertEqual(userSessionMock.userID, "userID")
    }
    
    func test_getUserID_throwError() async {
        // given
        let externalID = "error"
        
        // when
        await sut.getUserID(externalID)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_checkUserID_uptadeUserEmailCalled_withoutExternalID() async {
        // given
        userSessionMock.userID = "UserID"
        sut.email = "hello"
        
        // when
        await sut.checkUserID()
        
        // then
        XCTAssertTrue(sut.showNext)
    }
    
    func test_checkUserID_uptadeUserEmailCalled_withExternalID() async {
        // given
        userSessionMock.userID = "@externalID"
        sut.email = "hello"
        
        // when
        await sut.checkUserID()
        
        // then
        XCTAssertTrue(sut.showNext)
    }
    
    func test_checkUserID_getUserIDCalled_withExternalID() async {
        // given
        userSessionMock.userID = "Auth0@21!.UserID"
        sut.email = "hello"
        
        // when
        await sut.checkUserID()
        
        // then
        XCTAssertTrue(sut.showNext)
    }
    
    func test_getToken_didFetch() async {
        // given
        let model = RMFetchToken(
            clientId: "clientID",
            clientSecret: Environment.shared.sessionConfiguration.webClientSecret,
            audience: Environment.shared.sessionConfiguration.audienceUri,
            grantType: Environment.shared.sessionConfiguration.webGrantType)
        
        // when
        await sut.getToken(model: model)
        
        // then
        XCTAssertEqual("clientID", userSessionMock.token?.accessToken)
    }
    
    func test_getToken_didThrowError() async {
        let model = RMFetchToken(
            clientId: "Error",
            clientSecret: Environment.shared.sessionConfiguration.webClientSecret,
            audience: Environment.shared.sessionConfiguration.audienceUri,
            grantType: Environment.shared.sessionConfiguration.webGrantType)
        
        // when
        await sut.getToken(model: model)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_submit_didCallUpdateUserEmail() {
        // given
        let values: [EmailViewField: String] = [.email: "email@email.com"]
        userSessionMock.userID = "UserID"
        
        let expectation = XCTestExpectation(description: #function)
        
        let listener = sut.$showNext.sink { willShow in
            if willShow {
                expectation.fulfill()
            }
        }
        
        // when
        sut.submit(values: values)
        
        wait(for: [expectation], timeout: 3)
        
        listener.cancel()
        
        // then
        XCTAssertTrue(sut.showNext)
    }
    
    func test_submit_didCallGetToken() {
        // given
        let values: [EmailViewField: String] = [.email: "email@email.com"]

        let expectation = XCTestExpectation(description: #function)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        
        // when
        sut.submit(values: values)
        
        wait(for: [expectation], timeout: 3)
        
        // then
        XCTAssertTrue(loginSource.getTokenCalled)
    }
    
    func test_submit_didShowCustomError_emptyEmail() {
        // given
        let values: [EmailViewField: String] = [.email: ""]
        
        // when
        sut.submit(values: values)
        
        // then
        XCTAssertTrue(sut.showCustomError)
    }
    
    func test_submit_didShowCustomError_emptyValues() {
        // given
        let values: [EmailViewField: String] = [:]
        
        // when
        sut.submit(values: values)
        
        // then
        XCTAssertTrue(sut.showCustomError)
    }
}
