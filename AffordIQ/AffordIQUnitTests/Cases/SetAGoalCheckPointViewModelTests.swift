//
//  SetAGoalCheckPointViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 31/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
import Combine
@testable import AffordIQUI
@testable import AffordIQNetworkKit

class SetAGoalCheckPointViewModelTests: XCTestCase {
    var sut: SetAGoalCheckPointViewModel!
    var userSessionMock: UserSessionMock!
    var affordabilitySourceMock: AffordabilityServiceMock!
    
    override func setUp() {
        super.setUp()
        affordabilitySourceMock = AffordabilityServiceMock()
        userSessionMock = UserSessionMock.getMock()
        sut = SetAGoalCheckPointViewModel(viewType: .budget, getStartedType: .goal, mortgageAffordabilitySource: affordabilitySourceMock, userSession: userSessionMock, isBackAvailable: true)
    }
    
    override func tearDown() {
        sut = nil
        userSessionMock = nil
        affordabilitySourceMock = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Testing
    func test_getMonthsUntilAffordable_userIDNil_didThrow() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.getMonthsUntilAffordable()
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_getMonthsUntilAffordable_withNetworkError_didThrow() async {
        // given
        userSessionMock.userID = "error"
        
        // when
        await sut.getMonthsUntilAffordable()
        
        // then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? NetworkError, .badID)
    }
    
    func test_getMonthsUntilAffordable_monthNil() async {
        // given
        userSessionMock.userID = "workNil"
        
        // when
        await sut.getMonthsUntilAffordable()
        
        // then
        XCTAssertEqual(sut.months, 0)
    }
    
    func test_getMonthsUntilAffordable_monthEqual_didUpdateView() async {
        // given
        userSessionMock.userID = "work"
        let expectation = XCTestExpectation(description: #function)
        
        var willUpdate = false
        
        sut.willUpdate
            .sink { value in
                willUpdate = value
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.getMonthsUntilAffordable()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertEqual(sut.months, 12)
        XCTAssertTrue(willUpdate)
    }
}
