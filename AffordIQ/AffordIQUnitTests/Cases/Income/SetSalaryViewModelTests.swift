//
//  SetSalaryViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 29.11.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI

final class SetSalaryViewModelTests: XCTestCase {
    var sut: SetSalaryViewModel!
    
    override func setUp() {
        super.setUp()
        
        sut = SetSalaryViewModel(incomeData: nil, getStartedType: nil)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_next() {
        // when
        sut.showIncomeSummary(salary: "", bonus: "", monthly: "")
        
        // then
        XCTAssertTrue(sut.next)
    }
}
