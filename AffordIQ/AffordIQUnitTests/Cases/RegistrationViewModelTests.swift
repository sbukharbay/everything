//
//  RegistrationViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 10/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import XCTest
import Combine
@testable import AffordIQFoundation
@testable import AffordIQUI
@testable import AffordIQControls

class RegistrationViewModelTests: XCTestCase {
    var sut: RegistrationViewModel!
    var userSessionMock: UserSessionMock!
    var userServiceMock: UserServiceMock!
    
    override func setUp() {
        super.setUp()
        userSessionMock = UserSessionMock.getMock()
        userServiceMock = UserServiceMock()
        sut = RegistrationViewModel(userSource: userServiceMock, userSession: userSessionMock)
    }
    
    override func tearDown() {
        sut = nil
        userSessionMock = nil
        super.tearDown()
    }
    
    // MARK: - Given
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Testing
    func test_init() {
        // given
        let data = UserRegistrationData(dateOfBirth: "", firstName: "", lastName: "", mobilePhone: "", username: "alfi")
        
        // when
        let sut = RegistrationViewModel(data: data)
        
        // then
        XCTAssertEqual(data.username, sut.registrationData?.username)
    }
    
    func test_getValidationMessage_returnGivenNameString() {
        // given
        let field = RegistrationViewField.givenName
        let string = "Given name should be between 2 - 35 characters."
        
        // when
        let returnedString = sut.getValidationMessage(for: field)
        
        // then
        XCTAssertEqual(returnedString, string)
    }
    
    func test_getValidationMessage_returnFamilyNameString() {
        // given
        let field = RegistrationViewField.familyName
        let string = "Family name should be between 2 - 35 characters."
        
        // when
        let returnedString = sut.getValidationMessage(for: field)
        
        // then
        XCTAssertEqual(returnedString, string)
    }
    
    func test_isValidName_notValid_isShort() {
        // given
        let name = ""
        
        // when
        let isValid = sut.isValidName(name)
        
        // then
        XCTAssertFalse(isValid)
    }
    
    func test_isValidName_valid() {
        // given
        let name = "John Doe"
        
        // when
        let isValid = sut.isValidName(name)
        
        // then
        XCTAssertTrue(isValid)
    }
    
    func test_isValidName_notValid_isLong() {
        // given
        let name = "Lorem ipsum dolor sit amets consecte"
        
        // when
        let isValid = sut.isValidName(name)
        
        // then
        XCTAssertFalse(isValid)
    }
    
    func test_isValidPhoneNumber_notValid() {
        // given
        let number = "7701010101"
        
        // when
        let isValid = sut.isValidPhoneNumber(number)
        
        // then
        XCTAssertFalse(isValid)
    }
    
    func test_isValidPhoneNumber_valid() {
        // given
        let number = "+447701010101"
        
        // when
        let isValid = sut.isValidPhoneNumber(number)
        
        // then
        XCTAssertTrue(isValid)
    }
    
    func test_isValidEmail_notValid() {
        // given
        let email = "johndoe"
        
        // when
        let isValid = sut.isValidEmail(email)
        
        // then
        XCTAssertFalse(isValid)
    }
    
    func test_isValidEmail_valid() {
        // given
        let email = "johndoe@doe.com"
        
        // when
        let isValid = sut.isValidEmail(email)
        
        // then
        XCTAssertTrue(isValid)
    }
    
    func test_validationMessage_isValidMobileNumber() {
        // when
        let returnedMessage = sut.validationMessage(field: .mobileNumber, values: [.mobileNumber: "+447700000000"])
        
        // then
        XCTAssertNil(returnedMessage)
    }
    
    func test_validationMessage_isNotValidMobileNumber() {
        // given
        let message = "Please enter a valid phone number."
        
        // when
        let returnedMessage = sut.validationMessage(field: .mobileNumber, values: [.mobileNumber: "99"])
        
        // then
        XCTAssertEqual(message, returnedMessage)
    }
    
    func test_validationMessage_isValidEmailAddress() {
        // when
        let returnedMessage = sut.validationMessage(field: .emailAddress, values: [.emailAddress: "iosteam@blackarrowgroup.io"])
        
        // then
        XCTAssertNil(returnedMessage)
    }
    
    func test_validationMessage_isNotValidEmailAddress() {
        // given
        let message = "Please enter a valid email address."
        
        // when
        let returnedMessage = sut.validationMessage(field: .emailAddress, values: [.emailAddress: "affordiq.com"])
        
        // then
        XCTAssertEqual(message, returnedMessage)
    }
    
    func test_validationMessage_isValidPassword() {
        // when
        let returnedMessage = sut.validationMessage(field: .password, values: [.password: "Qwerty@123"])
        
        // then
        XCTAssertNil(returnedMessage)
    }
    
    func test_validationMessage_isNotValidPassword() {
        // given
        let message = "Please enter a valid password."
        
        // when
        let returnedMessage = sut.validationMessage(field: .password, values: [.password: "affordiq"])
        
        // then
        XCTAssertEqual(message, returnedMessage)
    }
    
    func test_validationMessage_isValidConfirmPassword() {
        // when
        let returnedMessage = sut.validationMessage(
            field: .confirmPassword,
            values: [.password: "Qwerty@123", .confirmPassword: "Qwerty@123"]
        )
        
        // then
        XCTAssertNil(returnedMessage)
    }
    
    func test_validationMessage_isNotValidConfirmPassword() {
        // given
        let message = "The passwords do not match."
        
        // when
        let returnedMessage = sut.validationMessage(field: .confirmPassword, values: [.confirmPassword: "affordiq"])
        
        // then
        XCTAssertEqual(message, returnedMessage)
    }
    
    func test_validationMessage_isValidDOB() {
        // when
        let returnedMessage = sut.validationMessage(
            field: .dateOfBirth,
            values: [.dateOfBirth: "01.01.2000"]
        )
        
        // then
        XCTAssertNil(returnedMessage)
    }
    
    func test_validationMessage_isNotValidDOB() {
        // given
        let message = "Please enter a value."
        
        // when
        let returnedMessage = sut.validationMessage(field: .dateOfBirth,
                                                    values: [.dateOfBirth: ""])
        
        // then
        XCTAssertEqual(message, returnedMessage)
    }
    
    func test_validationMessage_isValidGivenName() {
        // when
        let returnedMessage = sut.validationMessage(
            field: .givenName,
            values: [.givenName: "Alfi"]
        )
        
        // then
        XCTAssertNil(returnedMessage)
    }
    
    func test_validationMessage_isNotValidGivenName() {
        // given
        let message = "Given name should be between 2 - 35 characters."
        
        // when
        let returnedMessage = sut.validationMessage(field: .givenName,
                                                    values: [.givenName: "A"])
        
        // then
        XCTAssertEqual(message, returnedMessage)
    }
    
    func test_validationMessage_isValidLastName() {
        // when
        let returnedMessage = sut.validationMessage(
            field: .familyName,
            values: [.familyName: "Alfi"]
        )
        
        // then
        XCTAssertNil(returnedMessage)
    }
    
    func test_validationMessage_isNotValidLastName() {
        // given
        let message = "Family name should be between 2 - 35 characters."
        
        // when
        let returnedMessage = sut.validationMessage(field: .familyName,
                                                    values: [.familyName: "A"])
        
        // then
        XCTAssertEqual(message, returnedMessage)
    }
    
    func test_resetPassword_sendSuccess() async {
        // given
        userSessionMock.user = UserDetailsMock.getMock()
        sut.registrationData = UserRegistrationData(dateOfBirth: "", firstName: "", lastName: "", mobilePhone: "", username: "")
        
        var isSuccessful = false
        var isError = false
        
        let expectation = XCTestExpectation(description: #function)
        sut.resetPasswordSubject
            .sink { completion in
                switch completion {
                case .finished:
                    isSuccessful = true
                    expectation.fulfill()
                case .failure:
                    isError = true
                    expectation.fulfill()
                }
            } receiveValue: { _ in
                isSuccessful = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        // when
        await sut.resetPassword()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertFalse(isError)
        XCTAssertTrue(isSuccessful)
    }
    
    func test_resetPassword_didSendError() async {
        // given
        sut.registrationData = nil
        var isError = false
        var error: RegistrationError?
        let expectation = XCTestExpectation(description: #function)
        sut.resetPasswordSubject
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let receivedError):
                    isError = true
                    error = receivedError as? RegistrationError
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        // when
        await sut.resetPassword()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isError)
        XCTAssertEqual(error, .registrationDataNil)
    }
    
    func test_updateAccount_didUpdate() async {
        // given
        let dob = "01-01-2000"
        let mobileNumber = "+447700000000"
        let familyName = "AffordIQ"
        let givenName = "Alfi"
        userSessionMock.userID = "Hello"
        
        let expectation = XCTestExpectation(description: #function)
        
        var isCompleted = false
        sut.completeSubject
            .sink { _ in
                isCompleted = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.updateAccount(
            dateOfBirth: dob,
            mobileNumber: mobileNumber,
            familyName: familyName,
            givenName: givenName
        )
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isCompleted)
    }
    
    func test_updateAccount_didCatchError() async {
        // given
        let dob = "01-01-2000"
        let mobileNumber = "+447700000000"
        let familyName = "AffordIQ"
        let givenName = "Alfi"
        userSessionMock.userID = ""
        
        // when
        await sut.updateAccount(
            dateOfBirth: dob,
            mobileNumber: mobileNumber,
            familyName: familyName,
            givenName: givenName
        )
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_updateAccount_userSessionNil_didCatchError() async {
        // given
        let dob = "01-01-2000"
        let mobileNumber = "+447700000000"
        let familyName = "AffordIQ"
        let givenName = "Alfi"
        userSessionMock.userID = nil
        
        // when
        await sut.updateAccount(
            dateOfBirth: dob,
            mobileNumber: mobileNumber,
            familyName: familyName,
            givenName: givenName
        )
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_deleteAccountSucceeded_didSendSubject() {
        // given
        var isDeleted = false
        let expectation = XCTestExpectation(description: #function)
        sut.deleteAccountSubject
            .sink { _ in
                isDeleted = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        sut.deleteAccountSucceeded()
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isDeleted)
    }
    
    func test_registrationSucceeded_isSucceeded() {
        // given
        var isSucceeded = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.registrationSucceedSubject
            .sink { _ in
                isSucceeded = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        let model = RMCreateUser(
            firstName: "",
            lastName: "",
            mobilePhone: "",
            dateOfBirth: "",
            password: "",
            username: ""
        )
        
        // when
        sut.registrationSucceeded(userModel: model)
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isSucceeded)
    }
    
    func test_deleteAccount_deleteSucceeded() async {
        // given
        userSessionMock.userID = "success"
        var isDeleted = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.deleteAccountSubject
            .sink { _ in
                isDeleted = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.deleteAccount()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isDeleted)
    }
    
    func test_deleteAccount_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.deleteAccount()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_saveFieldsResults_didChangeRegistrationData() {
        // given
        let data = RMCreateUser(firstName: "Alfi", lastName: "AffordIQ", mobilePhone: "", dateOfBirth: "", password: "", username: "alfi@affordiq.com")
        
        // when
        sut.saveFieldsResults(data: data)
        
        // then
        XCTAssertEqual(sut.registrationData?.username, data.username)
    }
    
    func test_submitUserModel_registrationSucceeded() async {
        // given
        let createUserRequest = RMCreateUser(
            firstName: "",
            lastName: "",
            mobilePhone: "",
            dateOfBirth: "",
            password: "",
            username: "work"
        )
        
        var isSucceeded = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.registrationSucceedSubject
            .sink { _ in
                isSucceeded = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.submit(userModel: createUserRequest)
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isSucceeded)
    }
    
    func test_submitUserModel_didThrowError_userExists() async {
        // given
        let createUserRequest = RMCreateUser(
            firstName: "",
            lastName: "",
            mobilePhone: "",
            dateOfBirth: "",
            password: "",
            username: "error"
        )
        
        // when
        await sut.submit(userModel: createUserRequest)
        
        // then
        XCTAssertEqual(sut.registrationError, RegistrationError.userAlreadyExists.errorDescription)
    }
    
    func test_submitUserModel_didResponseThrowError() async {
        // given
        let createUserRequest = RMCreateUser(
            firstName: "",
            lastName: "",
            mobilePhone: "",
            dateOfBirth: "",
            password: "",
            username: "throw"
        )
        
        // when
        await sut.submit(userModel: createUserRequest)
        
        // then
        XCTAssertNotEqual(sut.registrationError, "")
    }
    
    func test_submitValues_registrationSucceeded() {
        // given
        let values = [RegistrationViewField: String]()
        
        var isSucceeded = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.registrationSucceedSubject
            .sink { _ in
                isSucceeded = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        sut.submit(values: values)
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isSucceeded)
    }
    
    func test_getUserData_didGetUserDetails() async {
        // given
        userSessionMock.userID = "work"
        let username = "alfi"
        
        // when
        await sut.getUserData()
        
        // then
        XCTAssertEqual(sut.registrationData?.username, username)
    }
    
    func test_registrationError_isDataNil() {
        // given
        let message = "Registration data is empty"
        let errorDescription = RegistrationError.registrationDataNil.errorDescription
        
        // then
        XCTAssertEqual(message, errorDescription)
    }
    
    func test_textFieldShouldReturn_tested() {
        // given
        let message = "Please enter a valid phone number."
        var isEqual = false
        let setter: MessageSetter = { returnedValue in
            if message == returnedValue {
                isEqual = true
            }
        }
        
        // when
        _ = sut.textFieldShouldReturn(field: .mobileNumber, messageSetters: [.mobileNumber: setter], values: [.mobileNumber: "90"])
        
        XCTAssertTrue(isEqual)
    }
}
