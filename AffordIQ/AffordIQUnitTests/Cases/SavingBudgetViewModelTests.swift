//
//  SavingBudgetViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 17/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
import Combine
@testable import AffordIQUI
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class SavingBudgetViewModelTests: XCTestCase {
    var sut: SavingBudgetViewModel!
    var userSessionMock: UserSessionMock!
    var affordabilitySourceMock: AffordabilityServiceMock!
    var spendingSourceMock: SpendingServiceMock!
    var goalSourceMock: GoalServiceMock!
    var amplitude: AmplitudeMock!
    
    override func setUp() {
        super.setUp()
        affordabilitySourceMock = AffordabilityServiceMock()
        userSessionMock = UserSessionMock.getMock()
        spendingSourceMock = SpendingServiceMock()
        goalSourceMock = GoalServiceMock()
        amplitude = AmplitudeMock()
        sut = SavingBudgetViewModel(
            affordabilitySource: affordabilitySourceMock,
            spendingSource: spendingSourceMock,
            goalSource: goalSourceMock,
            userSession: userSessionMock,
            amplitude: amplitude
        )
    }
    
    override func tearDown() {
        affordabilitySourceMock = nil
        userSessionMock = nil
        spendingSourceMock = nil
        goalSourceMock = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Given
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Testing
    func test_getMonthsUntilAffordableData_didUpdateView() async {
        // given
        userSessionMock.userID = "work"
        var isUpdated = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.updateSubject
            .sink { _ in
                isUpdated = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.getMonthsUntilAffordableData()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isUpdated)
    }
    
    func test_getMonthsUntilAffordableData_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.getMonthsUntilAffordableData()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_getSpendingSurplus_didUpdateView() async {
        // given
        userSessionMock.userID = "work"
        var isUpdated = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.updateSubject
            .sink { _ in
                isUpdated = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.getSpendingSurplus()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isUpdated)
    }
    
    func test_getSpendingSurplus_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.getSpendingSurplus()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_getTopCategories_didUpdateTable() async {
        // given
        userSessionMock.userID = "work"
        var isUpdated = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.updateTableSubject
            .sink { _ in
                isUpdated = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.getTopCategories()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isUpdated)
    }
    
    func test_getTopCategories_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.getTopCategories()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_spendingGoalCheck_didChangeCurrentSpend_spendingGoal_notNil() {
        // given
        let model = TopAverageSpendingModel(categoryName: "category 1", categoryId: 1, averageSpend: MonetaryAmount(amount: 100), spendingGoal: MonetaryAmount(amount: 100), order: 1)
        sut.currentIndex = 0
        sut.topCategories = []
        sut.topCategories.append(model)
        
        // when
        sut.spendingGoalCheck()
        
        // then
        XCTAssertEqual(sut.currentSpend, Int((model.spendingGoal?.amount!.doubleValue)!))
    }
    
    func test_spendingGoalCheck_didChangeCurrentSpend_spendingGoal_nil() {
        // given
        let model = TopAverageSpendingModel(categoryName: "category 1", categoryId: 1, averageSpend: MonetaryAmount(amount: 100), spendingGoal: MonetaryAmount(amount: nil), order: 1)
        sut.currentIndex = 0
        sut.topCategories = []
        sut.topCategories.append(model)
        
        // when
        sut.spendingGoalCheck()
        
        // then
        XCTAssertEqual(sut.currentSpend, 0)
    }
    
    func test_spendingGoalCheck_didChangeCurrentSpend_averageSpend_notNil() {
        // given
        let model = TopAverageSpendingModel(categoryName: "category 1", categoryId: 1, averageSpend: MonetaryAmount(amount: 100), order: 1)
        sut.currentIndex = 0
        sut.topCategories = []
        sut.topCategories.append(model)
        
        // when
        sut.spendingGoalCheck()
        
        // then
        XCTAssertEqual(sut.currentSpend, Int((model.averageSpend.amount?.doubleValue)!))
    }
    
    func test_spendingGoalCheck_didChangeCurrentSpend_averageSpend_nil() {
        // given
        let model = TopAverageSpendingModel(categoryName: "category 1", categoryId: 1, averageSpend: MonetaryAmount(amount: nil), order: 1)
        sut.currentIndex = 0
        sut.topCategories = []
        sut.topCategories.append(model)
        
        // when
        sut.spendingGoalCheck()
        
        // then
        XCTAssertEqual(sut.currentSpend, 0)
    }
    
    func test_confirmNewSpendingTarget_withIndex() {
        // given
        let spendingModel = TopAverageSpendingModel(categoryName: "category 1", categoryId: 1, averageSpend: MonetaryAmount(amount: 200), spendingGoal: MonetaryAmount(amount: 200), order: 1)
        let targetModel = RMSpendingTarget(categoryId: 1, categoryName: "category 1", id: 1, monthlySpendingTarget: MonetaryAmount(amount: 100))
        sut.currentIndex = 0
        
        sut.topCategories = []
        sut.topCategories.append(spendingModel)
        
        sut.savedCategories = []
        sut.savedCategories.append(targetModel)
        
        // when
        sut.confirmNewSpendingTarget()
        
        // then
        XCTAssertEqual(sut.savedCategories[0].monthlySpendingTarget.amount, spendingModel.averageSpend.amount)
    }
    
    func test_confirmNewSpendingTarget_withoutIndex() {
        // given
        let spendingModel = TopAverageSpendingModel(categoryName: "category 1", categoryId: 2, averageSpend: MonetaryAmount(amount: 200), spendingGoal: MonetaryAmount(amount: 200), order: 1)
        let targetModel = RMSpendingTarget(categoryId: 1, categoryName: "category 1", id: 1, monthlySpendingTarget: MonetaryAmount(amount: 100))
        sut.currentIndex = 0
        
        sut.topCategories = []
        sut.topCategories.append(spendingModel)
        
        sut.savedCategories = []
        sut.savedCategories.append(targetModel)
        
        // when
        sut.confirmNewSpendingTarget()
        
        // then
        XCTAssertEqual(sut.savedCategories[1].categoryId, spendingModel.categoryId)
    }
    
    func test_setMonthlySavingsGoal_didSendonboardingComplete() async {
        // given
        userSessionMock.userID = "work"
        var isCompleted = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.onboardingCompleteSubject
            .sink { _ in
                isCompleted = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.setMonthlySavingsGoal()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isCompleted)
    }
    
    func test_setMonthlySavingsGoal_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.setMonthlySavingsGoal()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_onboardingCompleteStep_didLog() {
        // when
        sut.onboardingCompleteStep()
        
        // then
        XCTAssertTrue(amplitude.isLogged)
    }
}
