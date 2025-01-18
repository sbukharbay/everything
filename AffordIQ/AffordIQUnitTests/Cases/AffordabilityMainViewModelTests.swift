//
//  AffordabilityMainViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 23.11.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class AffordabilityMainViewModelTests: XCTestCase {
    var sut: AffordabilityMainViewModel!
    private var affordabilitySourceMock: AffordabilityServiceMock!
    private var userSessionMock: UserSessionMock!
    
    override func setUp() {
        super.setUp()
        
        affordabilitySourceMock = AffordabilityServiceMock()
        userSessionMock = UserSessionMock.getMock()
        userSessionMock.userID = "userID"
        
        sut = AffordabilityMainViewModel(type: .setGoal, getStartedType: .goal, affordabilitySource: affordabilitySourceMock, userSession: userSessionMock, isDashboard: false)
    }
    
    override func tearDown() {
        sut = nil
        affordabilitySourceMock = nil
        userSessionMock = nil
        super.tearDown()
    }

    func test_showPropertySearch() {
        // when
        _ = sut.firstValidMonthlyPeriod
        sut.showPropertySearch()
        
        // then
        XCTAssertFalse(sut.isDone)
    }
    
    func test_showResults() {
        // given
        sut.viewType = .filter(search: ChosenPropertyParameters(suggestion: Suggestion(value: "Glasgow"), homeValue: 100000.0), mortgageLimits: nil)
        
        // when
        sut.showResults()
        
        // then
        XCTAssertNotNil(sut.filters)
    }
    
    func test_setOverlayData() {
        // given
        sut.viewType = .tabbar
        sut.mortgageDetails = MortgageDetails(mortgage: MonetaryAmount(amount: 100000.0), repayment: MonetaryAmount(amount: 1000.0), interestRate: 11, term: 12)
        // when
        sut.setOverlayData()
        
        // then
        XCTAssertNotNil(sut.overlayData)
    }
    
    func test_getAffordabilityCalculations_didThrowError() async {
        // given
        userSessionMock.userID = "error"
        
        // when
        await sut.getAffordabilityCalculations()
        
        // then
        XCTAssertNotNil(sut.error)
    }
}
