//
//  ConfirmIncomeViewModelTests.swift
//  AffordIQ
//
//  Created by Asilbek Djamaldinov on 19/04/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class ConfirmIncomeViewModelTests: XCTestCase {
    var sut: ConfirmIncomeViewModel!
    private var affordabilitySourceMock: AffordabilityServiceMock!
    private var userSourceMock: UserServiceMock!
    private var userSessionMock: UserSessionMock!
    
    override func setUp() {
        super.setUp()
        
        affordabilitySourceMock = AffordabilityServiceMock()
        userSourceMock = UserServiceMock()
        userSessionMock = UserSessionMock.getMock()
        userSessionMock.userID = "employed"
        
        sut = ConfirmIncomeViewModel(
            incomeData: IncomeStatusDataModel(employmentStatus: .employed, salary: "200000.0", bonus: "0.0", monthly: "16000.0"),
            getStartedType: .goal,
            isBack: true,
            isSettings: false,
            affordabilitySource: affordabilitySourceMock,
            userSource: userSourceMock,
            userSession: userSessionMock)
    }
    
    override func tearDown() {
        sut = nil
        affordabilitySourceMock = nil
        userSourceMock = nil
        userSessionMock = nil
        super.tearDown()
    }
    
    func test_getIncomeBreakdown_selfEmployed() async {
        // given
        userSessionMock.userID = "selfEmployed"
        
        // when
        await sut.getIncomeBreakdown()
        
        // then
        XCTAssertNotNil(sut.incomeData)
    }
    
    func test_getIncomeBreakdown_didThrowError() async {
        // given
        userSessionMock.userID = ""
        
        // when
        await sut.getIncomeBreakdown()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_setConfirmIncome() {
        // when
        Task { await sut.setConfirmIncome() }
        
        // then
        XCTAssertNotNil(sut.didOperationCompleteSubject)
    }
    
    func test_setConfirmIncome_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.setConfirmIncome()
        
        // then
        XCTAssertNotNil(sut.didOperationCompleteSubject)
    }
    
    func test_setIncomeStatus_selfEmployed() async {
        // given
        sut.incomeData?.employmentStatus = .selfEmployed
        sut.incomeData?.selfEmploymentData = .init(type: .director)
        
        // when
        await sut.setIncomeStatus(userID: "userID")
        
        // then
        XCTAssertNotNil(sut.didOperationCompleteSubject)
    }
}
