//
//  BudgetDetailsViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 03.01.2024.
//  Copyright © 2024 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class BudgetDetailsViewModelTests: XCTestCase {
    var sut: BudgetDetailsViewModel!
    var goalSourceMock: GoalServiceMock!
    private var userSessionMock: UserSessionMock!
    
    override func setUp() {
        super.setUp()
        
        goalSourceMock = GoalServiceMock()
        userSessionMock = UserSessionMock.getMock()
        userSessionMock.userID = "userID"
        
        let spending = SpendingBreakdownCategory(order: 1, id: 1, 
                                                 name: "Grocery",
                                                 actualSpend: MonetaryAmount(amount: 250.0),
                                                 spendingGoal: MonetaryAmount(amount: 230.0),
                                                 monthlyAverage: MonetaryAmount(amount: 350.0),
                                                 parentCategoryName: "HouseHold",
                                                 spendGoalPercentage: 0.5)
        
        sut = BudgetDetailsViewModel(session: userSessionMock,
                                     goalSource: goalSourceMock,
                                     styles: AppStyles.shared,
                                     spending: spending)
    }
    
    override func tearDown() {
        sut = nil
        goalSourceMock = nil
        userSessionMock = nil
        super.tearDown()
    }

    func test_setMonthlySavingsGoal() async {
        // when
        await sut.setMonthlySavingsGoal(MonetaryAmount(amount: 120.0))
        
        // then
        XCTAssertTrue(sut.operationComplete)
    }
    
    func test_setMonthlySavingsGoal_didThrowError() async {
        // given
        userSessionMock.userID = "error"
        
        // when
        await sut.setMonthlySavingsGoal(MonetaryAmount(amount: 120.0))
        
        // then
        XCTAssertNotNil(sut.error)
    }
}
