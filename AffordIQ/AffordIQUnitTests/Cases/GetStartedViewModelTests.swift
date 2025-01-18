//
//  GetStartedViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 05.10.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI

final class GetStartedViewModelTests: XCTestCase {
    var sut: GetStartedViewModel?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_init() throws {
        // when
        sut = GetStartedViewModel()
        
        // then
        XCTAssertNotNil(sut?.getStartedData)
        XCTAssertNotNil(sut?.ownYourFinancesData)
        XCTAssertNotNil(sut?.ownYourFutureData)
    }
}
