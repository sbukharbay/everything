//
//  EmploymentStatusViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 27.11.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class EmploymentStatusViewModelTests: XCTestCase {
    var sut: EmploymentStatusViewModel!
    
    override func setUp() {
        super.setUp()
        
        sut = EmploymentStatusViewModel(incomeData: IncomeStatusDataModel(employmentStatus: .employed, salary: "200000.0", bonus: "0.0", monthly: "16000.0"), getStartedType: .goal, isSettings: false)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_showNext() {
        // when
        sut.showNext(.init(status: .employed, selected: true))
        
        // then
        XCTAssertTrue(sut.showNext)
    }
    
    func test_confirmIncomeSummary_confirmIncome() {
        // when
        sut.confirmIncomeSummary(.init(status: .employed, selected: true))
        
        // then
        XCTAssertTrue(sut.confirmIncome)
    }
    
    func test_confirmIncomeSummary() {
        // given
        sut.incomeData?.salary = ""
        
        // when
        sut.confirmIncomeSummary(.init(status: .employed, selected: true))
        
        // then
        XCTAssertFalse(sut.isSelfEmployed)
    }
    
    func test_confirmIncomeSummary_selfEmployed() {
        // given
        sut.incomeData?.employmentStatus = .selfEmployed
        
        // when
        sut.confirmIncomeSummary(.init(status: .selfEmployed, selected: true))
        
        // then
        XCTAssertTrue(sut.isSelfEmployed)
    }
    
    func test_showNext_noIncomeData() {
        // given
        sut.incomeData = nil
        
        // when
        sut.showNext(.init(status: .employed, selected: true))
        
        // then
        XCTAssertTrue(sut.showNext)
    }
}
