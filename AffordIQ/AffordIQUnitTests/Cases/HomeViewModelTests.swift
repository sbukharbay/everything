//
//  HomeViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 22/08/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

class HomeViewModelTests: XCTestCase {
    private var sut: HomeViewModel!
    private var userSourceMock: UserServiceMock!
    private var userSessionMock: UserSessionMock!
    private var spendingSourceMock: SpendingServiceMock!
    private var accountsSourceMock: AccountsServiceMock!
    private var affordabilitySourceMock: AffordabilityServiceMock!
    
    override func setUp() {
        super.setUp()
        
        userSourceMock = UserServiceMock()
        userSessionMock = UserSessionMock.getMock()
        spendingSourceMock = SpendingServiceMock()
        accountsSourceMock = AccountsServiceMock()
        affordabilitySourceMock = AffordabilityServiceMock()
        
        sut = HomeViewModel(
            userSource: userSourceMock,
            spendingSource: spendingSourceMock,
            accountsSource: accountsSourceMock,
            affordabilitySource: affordabilitySourceMock,
            userSession: userSessionMock)
    }
    
    override func tearDown() {
        sut = nil
        userSourceMock = nil
        userSessionMock = nil
        spendingSourceMock = nil
        accountsSourceMock = nil
        affordabilitySourceMock = nil
        super.tearDown()
    }
    
    func test_init_withUsername_didSetName() {
        // given
        let name = "John"
        
        // then
        XCTAssertEqual(userSessionMock.user?.givenName, name)
    }
    
    func test_init_withoutUsername_didCallGetUserName() async {
        // given
        userSessionMock.userID = "UserID"
        userSessionMock.user = nil
        let expectation = XCTestExpectation(description: #function)
        
        // when
        sut = HomeViewModel(userSource: userSourceMock, userSession: userSessionMock)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(userSourceMock.didGetUserDetailsCall)
    }
    
    func test_budgetCalculations_didCaseBreakTake() {
        // given
        let response: DiscretionaryMonthlyBudgetResponse = .init(targetSpend: MonetaryAmount(amount: 0), leftToSpend: MonetaryAmount(amount: 0), pattern: .break)
        let resultText = "✋ You are on track to break your budget this month."
        
        // when
        sut.budgetCalculations(response)
        
        // then
        XCTAssertEqual(sut.updateBottom?.info, resultText)
    }
    
    func test_budgetCalculations_didCaseMeetTake() {
        // given
        let response: DiscretionaryMonthlyBudgetResponse = .init(targetSpend: MonetaryAmount(amount: 0), leftToSpend: MonetaryAmount(amount: 0), pattern: .meet)
        let resultText = "👍 You are on track to meet your budget this month."
        
        // when
        sut.budgetCalculations(response)
        
        // then
        XCTAssertEqual(sut.updateBottom?.info, resultText)
    }
    
    func test_budgetCalculations_didCaseExcededTake() {
        // given
        let response: DiscretionaryMonthlyBudgetResponse = .init(targetSpend: MonetaryAmount(amount: 0), leftToSpend: MonetaryAmount(amount: 0), pattern: .exceeded)
        let resultText = "🙁 You have exceeded your budget for this month. This may effect the time it takes to complete your goal."
        
        // when
        sut.budgetCalculations(response)
        
        // then
        XCTAssertEqual(sut.updateBottom?.info, resultText)
    }
    
    func test_getUserName_throwError() async {
        // given
        userSessionMock.userID = "error"
        
        // when
        await sut.getUserName()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_getUserName_didReturn() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.getUserName()
        
        // then
        XCTAssertNil(sut.error)
    }
    
    func test_mortgageAffordability_isSavingsGoalNil() async {
        // given
        let id = "work"
        
        // when
        await sut.mortgageAffordability(id)
        
        // then
        XCTAssertEqual(sut.savingsGoal, "N/A")
    }
    
    func test_mortgageAffordability_didThrowError() async {
        // given
        let id = "error"
        
        // when
        await sut.mortgageAffordability(id)
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_checkConsent_isReconsentTrue() async {
        // given
        userSessionMock.userID = "work"
        
        // when
        await sut.checkConsent()
        
        // then
        XCTAssertTrue(sut.reconsent)
    }
    
    func test_progressBarAmount() {
        // given
        sut.updateTop = PropertyGoalAndMortgageLimitsResponse(
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
        sut.updateTop = nil
        
        // when
        let amount = sut.progressBarAmount
        
        // then
        XCTAssertEqual(amount, Float(0))
    }
}
