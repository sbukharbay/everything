//
//  SelfEmployedProfitViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 29.11.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI

final class SelfEmployedProfitViewModelTests: XCTestCase {
    var sut: SelfEmployedProfitViewModel!
    
    override func setUp() {
        super.setUp()
        
        sut = SelfEmployedProfitViewModel(incomeData: IncomeStatusDataModel(employmentStatus: .employed, salary: "200000", bonus: "100000", monthly: "20000", selfEmploymentData: SelfEmploymentData(type: .contractor, months: 20)), getStartedType: nil)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_next_moreThan24Months() {
        // given
        sut.incomeData?.selfEmploymentData?.months = 25
        
        // when
        sut.next("200000.0", "180000.0")
        
        // then
        XCTAssertTrue(sut.next)
    }
    
    func test_next_lessThan24Months() {
        // given
        sut.incomeData?.selfEmploymentData?.months = 12
        
        // when
        sut.next("200000.0", "180000.0")
        
        // then
        XCTAssertTrue(sut.next)
    }
}
