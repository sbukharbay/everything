//
//  SelfEmployedTimeViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 29.11.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class SelfEmployedTimeViewModelTests: XCTestCase {
    var sut: SelfEmployedTimeViewModel!
    
    override func setUp() {
        super.setUp()
        
        sut = SelfEmployedTimeViewModel(incomeData: IncomeStatusDataModel(employmentStatus: .employed, salary: "200000", bonus: "100000", monthly: "20000", selfEmploymentData: SelfEmploymentData(type: .contractor, months: 20)), getStartedType: nil)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_setData_return() {
        // given
        sut.selectedYear = nil
        sut.selectedMonth = nil
        
        // when
        sut.setData()
        
        // then
        XCTAssertFalse(sut.update)
    }
    
    func test_setData_moreThan24Months() {
        // given
        sut.selectedYear = 4
        sut.selectedMonth = 3
        
        // when
        sut.setData()
        
        // then
        XCTAssertTrue(sut.next)
    }
    
    func test_setData_lessThan24Months() {
        // given
        sut.selectedYear = 1
        sut.selectedMonth = 6
        
        // when
        sut.setData()
        
        // then
        XCTAssertTrue(sut.update)
    }
    
    func test_setData_lessThan12Months() {
        // given
        sut.selectedYear = 0
        sut.selectedMonth = 6
        sut.initialMonths = 25
        
        // when
        sut.setData()
        
        // then
        XCTAssertTrue(sut.showImportant)
    }
}
