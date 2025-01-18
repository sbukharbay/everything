//
//  GoalsViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 24/08/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

class GoalsViewModelTests: XCTestCase {
    private var sut: GoalsViewModel!
    private var affordabilitySourceMock: AffordabilityServiceMock!
    private var userSessionMock: UserSessionMock!
    
    override func setUp() {
        super.setUp()
        
        affordabilitySourceMock = AffordabilityServiceMock()
        userSessionMock = UserSessionMock.getMock()
        
        sut = GoalsViewModel(
            affordabilitySource: affordabilitySourceMock,
            userSession: userSessionMock
        )
    }
    
    override func tearDown() {
        sut = nil
        affordabilitySourceMock = nil
        userSessionMock = nil
        super.tearDown()
    }
    
    // MARK: - Helper
    var property: PropertyGoalAndMortgageLimitsResponse {
        PropertyGoalAndMortgageLimitsResponse(
            description: "",
            errors: [],
            message: "",
            monthsUntilAffordable: 12,
            mortgageLimits: nil,
            propertyGoal: nil,
            mortgageGoal: nil,
            targetDeposit: nil,
            savingsGoal: nil,
            statusCode: 200,
            userId: "",
            fees: nil,
            depositGoal: nil
        )
    }
    
    func getMortgageData() {
        sut.mortgageDetails = MortgageDetails(
            mortgage: MonetaryAmount(amount: 100),
            repayment: MonetaryAmount(amount: 100),
            interestRate: 4,
            term: 12
        )
        
        sut.mortgageLimits = PropertyGoalAndMortgageLimitsResponse(
            description: "",
            errors: [],
            message: "",
            monthsUntilAffordable: 12,
            mortgageLimits: nil,
            propertyGoal: nil,
            mortgageGoal: nil,
            targetDeposit: nil,
            savingsGoal: nil,
            statusCode: 200,
            userId: "",
            fees: nil,
            depositGoal: nil
        )
    }
    
    // MARK: - Testing
    func test_setOverlayData_didUpdateBottom() {
        // given
        getMortgageData()
        
        // when
        sut.setOverlayData()
        
        // then
        XCTAssertTrue(sut.willUpdateBottom)
    }
    
    func test_setOverlayData_didReturn() {
        // given
        sut.mortgageDetails = nil
        
        // when
        sut.setOverlayData()
        
        // then
        XCTAssertFalse(sut.willUpdateBottom)
    }
    
    func test_getMortgageDetails_didGetDetails() async {
        // given
        let resultDetails = MortgageDetails(
            mortgage: MonetaryAmount(amount: 100),
            repayment: MonetaryAmount(amount: 100),
            interestRate: 4,
            term: 12
        )
        userSessionMock.userID = "work"
        let expectation = XCTestExpectation(description: #function)
        
        // when
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        sut.getMortgageDetails(property: property, deposit: 30)
        
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertEqual(sut.mortgageDetails, resultDetails)
    }
    
    func test_getMortgageDetails_didReturn() {
        // given
        userSessionMock.userID = nil
        
        // when
        sut.getMortgageDetails(property: property, deposit: 30)
        
        // then
        XCTAssertNil(sut.error)
    }
    
    func test_getMortgageDetails_didThrowError() async {
        // given
        userSessionMock.userID = "error"
        let expectation = XCTestExpectation(description: #function)
        
        // when
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        sut.getMortgageDetails(property: property, deposit: 30)
        
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_getMortgageAffordability_didUpdateBottom() async {
        // given
        userSessionMock.userID = "work"
        
        // when
        await sut.getMortgageAffordability()
        
        // then
        XCTAssertNotNil(sut.mortgageLimits)
    }
    
    func test_getMortgageAffordability_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.getMortgageAffordability()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_resume_didThrowError() async {
        // given
        userSessionMock.userID = nil
        let expectation = XCTestExpectation(description: #function)
        
        // when
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        sut.resume()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_progressBarAmount() {
        // given
        sut.mortgageLimits = PropertyGoalAndMortgageLimitsResponse(
            description: nil,
            errors: nil,
            message: nil,
            monthsUntilAffordable: nil,
            mortgageLimits: MortgageLimits(
                currentAffordability: MonetaryAmount(amount: 2),
                currentDeposit: MonetaryAmount(amount: 50),
                maximumPossibleMortgage: MonetaryAmount(amount: 2),
                currentExternalCapital: MonetaryAmount(amount: 2),
                repaymentCapacity: MonetaryAmount(amount: 2)
            ),
            propertyGoal: nil,
            mortgageGoal: nil,
            targetDeposit: MonetaryAmount(amount: 2),
            savingsGoal: nil,
            statusCode: 200,
            userId: "",
            fees: nil,
            depositGoal: nil
        )
        
        // when
        let amount = sut.progressBarAmount
        
        // then
        XCTAssertEqual(amount, Float(25))
    }
    
    func test_progressBarAmount_zero() {
        // given
        sut.mortgageLimits = nil
        
        // when
        let amount = sut.progressBarAmount
        
        // then
        XCTAssertEqual(amount, Float(0))
    }
}
