//
//  SetSavingsGoalViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 31/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
import Combine
@testable import AffordIQUI
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class SetSavingsGoalViewModelTests: XCTestCase {
    var sut: SetSavingsGoalViewModel!
    var userSessionMock: UserSessionMock!
    var spendingSourceMock: SpendingServiceMock!
    var goalSourceMock: GoalServiceMock!
    
    override func setUp() {
        super.setUp()
        goalSourceMock = GoalServiceMock()
        spendingSourceMock = SpendingServiceMock()
        userSessionMock = UserSessionMock.getMock()
        
        sut = SetSavingsGoalViewModel(
            isDashboard: false,
            goalSource: goalSourceMock,
            spendingSource: spendingSourceMock,
            userSession: userSessionMock
        )
    }
    
    override func tearDown() {
        sut = nil
        userSessionMock = nil
        spendingSourceMock = nil
        goalSourceMock = nil
        super.tearDown()
    }
    
    // MARK: - Given
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Testing
    func test_updateSurplus_withNilUserID_didThrow() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.updateSurplus()
    
        // then
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_updateSurplus_surplusLess0_didSetViewForZero() async {
        // given
        userSessionMock.userID = "surplus"
        var didSetup = false
        
        let expectation = XCTestExpectation(description: #function)
        sut.setupViewsForZeroSurplusSubject
            .sink { _ in
                didSetup = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.updateSurplus()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(didSetup)
    }
    
    func test_updateSurplus_didSetSurplus() async {
        // given
        userSessionMock.userID = "work"
        var didSet = false
        
        let expectation = XCTestExpectation(description: #function)
        sut.setSurplusSubject
            .sink { _ in
                didSet = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.updateSurplus()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(didSet)
    }
    
    func test_getSavingsGoal_withNilUserID_didThrow() async {
        // given
        userSessionMock.userID = nil
        let expectation = XCTestExpectation()
        sut.changeSliderSubject
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        _ = await sut.getSavingsGoal()
        
        // then
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    func test_getSavingsGoal_getSavingAmount() async {
        // given
        userSessionMock.userID = "work"
        
        // when
        let savingAmount = await sut.getSavingsGoal()
        
        // then
        XCTAssertEqual(savingAmount, 100)
    }
    
    func test_getSavingsGoal_withNetworkDecodeError_didThrow() async {
        // given
        userSessionMock.userID = "decodeFail"
        let expectation = XCTestExpectation()
        sut.surplus = MonetaryAmount(amount: 100.0)
        
        sut.changeSliderSubject
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        _ = await sut.getSavingsGoal()
        
        // then
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    func test_updateGoal_goalGreater() async {
        // given
        sut.surplus = MonetaryAmount(amount: 50)
        userSessionMock.userID = "work"
        var amount: Float = 0.0
        
        let expectation = XCTestExpectation(description: #function)
        sut.changeSliderSubject
            .sink { value in
                amount = value
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        _ = await sut.updateGoal()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertEqual(amount, Float(25.0))
    }
    
    func test_updateGoal_surplusGreater() async {
        // given
        sut.surplus = MonetaryAmount(amount: 150)
        userSessionMock.userID = "work"
        var amount: Float = 0.0
        
        let expectation = XCTestExpectation(description: #function)
        sut.changeSliderSubject
            .sink { value in
                amount = value
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        _ = await sut.updateGoal()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertEqual(amount, Float(100.0))
    }
    
    func test_postSavingsGoal_withNilUserID_didThrow() async {
        // given
        userSessionMock.userID = nil
        let model = RMSavingGoalSet(monthlySavingsAmount: MonetaryAmount(amount: 100))
        
        // when
        _ = await sut.postSavingsGoal(model: model)
        
        // then
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_postSavingsGoal_didCompleteOperation() async {
        // given
        userSessionMock.userID = "work"
        var didComplete = false
        let model = RMSavingGoalSet(monthlySavingsAmount: MonetaryAmount(amount: 100))
        
        let expectation = XCTestExpectation(description: #function)
        sut.operationCompleteSubject
            .sink { receivedValue in
                didComplete = receivedValue
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        _ = await sut.postSavingsGoal(model: model)
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(didComplete)
    }
    
    func test_postSavingsGoal_withNetworkError_didThrow() async {
        // given
        userSessionMock.userID = "error"
        let model = RMSavingGoalSet(monthlySavingsAmount: MonetaryAmount(amount: 100))
        
        // when
        _ = await sut.postSavingsGoal(model: model)
        
        // then
        XCTAssertEqual(sut.error as? NetworkError, NetworkError.badID)
    }
    
    func test_setSavingsGoal_didCallNetwork() {
        // given
        userSessionMock.userID = "work"
        var didComplete = false
        
        let expectation = XCTestExpectation(description: #function)
        sut.operationCompleteSubject
            .sink { receivedValue in
                didComplete = receivedValue
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        sut.setSavingsGoal(savingsGoal: "hello")
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(didComplete)
    }
}
