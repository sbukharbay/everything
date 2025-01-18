//
//  SelfEmployedTypeViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 29.11.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI

final class SelfEmployedTypeViewModelTests: XCTestCase {
    var sut: SelfEmployedTypeViewModel!
    
    override func setUp() {
        super.setUp()
        
        sut = SelfEmployedTypeViewModel(incomeData: IncomeStatusDataModel(employmentStatus: .employed, salary: "200000", bonus: "100000", monthly: "20000", selfEmploymentData: SelfEmploymentData(type: .contractor, months: 20)), getStartedType: nil)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_next() {
        // when
        sut.next()
        
        // then
        XCTAssertTrue(sut.showNext)
    }
    
    func test_next_noType() {
        // given
        sut.incomeData?.selfEmploymentData = nil
        
        // when
        sut.next()
        
        // then
        XCTAssertTrue(sut.showNext)
    }
}
