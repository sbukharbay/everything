//
//  SetDepositViewModelTests.swift
//  AffordIQNetworkKitTests
//
//  Created by Sultangazy Bukharbay on 29/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
import Combine
@testable import AffordIQUI
@testable import AffordIQNetworkKit

class SetDepositViewModelTests: XCTestCase {
    var sut: SetDepositViewModel!
    var userSessionMock: UserSessionMock!
    var affordabilitySourceMock: AffordabilityServiceMock!
    var goalSourceMock: GoalServiceMock!
    
    override func setUp() {
        super.setUp()
        userSessionMock = UserSessionMock.getMock()
        affordabilitySourceMock = AffordabilityServiceMock()
        goalSourceMock = GoalServiceMock()
        sut = SetDepositViewModel(
            goalSource: goalSourceMock,
            userSession: userSessionMock,
            affordabilitySource: affordabilitySourceMock,
            isDashboard: false
        )
    }
    
    override func tearDown() {
        sut = nil
        userSessionMock = nil
        affordabilitySourceMock = nil
        goalSourceMock = nil
        super.tearDown()
    }
    
    // MARK: - Given
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Testing
    func test_init_throwError() {
        // given
        userSessionMock.userID = nil
        let expectation = XCTestExpectation(description: #function)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        
        // when
        sut = SetDepositViewModel(userSession: userSessionMock, isDashboard: false)
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_getAffordabilityPreview_withNilUserID_didThrow() async {
        // given
        userSessionMock.userID = nil
        
        // when
        do {
            try await sut.getAffordabilityPreview()
        } catch {
            sut.error = error
        }
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_getAffordabilityPreview_withNetworkError_didThrow() async {
        // given
        userSessionMock.userID = "error"
        
        // when
        do {
            try await sut.getAffordabilityPreview()
        } catch {
            sut.error = error
        }
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .badID)
    }
    
    func test_getAffordabilityPreview_didSendUpdate() async {
        // given
        let currentDeposit: Decimal = 10
        let expectation = XCTestExpectation(description: #function)
        
        var willUpdate = false
        
        userSessionMock.userID = "userID"
        sut.updateSubject
            .sink { value in
                willUpdate = value
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        try? await sut.getAffordabilityPreview()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(willUpdate)
        XCTAssertEqual(sut.currentDeposit?.amount, currentDeposit)
    }
    
    func test_getDepositGoal_withNilUserID_didThrow() async {
        // given
        userSessionMock.userID = nil
        
        // when
        do {
            try await sut.getDepositGoal()
        } catch {
            sut.error = error
        }
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_getDepositGoal_withNetworkError_didThrow() async {
        // given
        userSessionMock.userID = "error"
        
        // when
        do {
            try await sut.getDepositGoal()
        } catch {
            sut.error = error
        }
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .badID)
    }
    
    func test_getDepositGoal_didSetSlider() async {
        // given
        let loanToValueData: Float = 90.0
        let expectation = XCTestExpectation(description: #function)
        
        var willSetSlider = false
        
        userSessionMock.userID = "userID"
        sut.setSliderSubject
            .sink { value in
                willSetSlider = value
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        try? await sut.getDepositGoal()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(willSetSlider)
        XCTAssertEqual(sut.loanToValueData, loanToValueData)
    }
    
    func test_getDepositGoal_didLoanToValueData_isDefault() async {
        // given
        userSessionMock.userID = "depositGoalNil"
        let loanToValueData: Float = 10.0
        
        // when
        try? await sut.getDepositGoal()
        
        // then
        XCTAssertEqual(sut.loanToValueData, loanToValueData)
    }
    
    func test_setDepositGoal_withNilUserID_didThrow() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.setDepositGoal()
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_setDepositGoal_withNetworkError_didThrow() async {
        // given
        userSessionMock.userID = "error"
        
        // when
        await sut.setDepositGoal()
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .badID)
    }
    
    func test_setDepositGoal_didCompleteOperation() async {
        // given
        let expectation = XCTestExpectation(description: #function)
        
        var willCompleteOperation = false
        
        userSessionMock.userID = "userID"
        sut.setSliderSubject
            .sink { value in
                willCompleteOperation = value
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        try? await sut.getDepositGoal()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(willCompleteOperation)
    }
}
